class SyncCalendarJob < GoogleCalendarJob
  queue_as :default

  def perform(calendar_id)
    calendar = Calendar.find(calendar_id)
    user = calendar.user

    begin
      service = init_google_service(user)

      sync_events(service, calendar)
    rescue StandardError => e
      # create sync notification for the user when the sync fails
      SyncErrorNotification.create(user: user, message: e.message)

      # log the error
      Rails.logger.error "error syncing calendar #{calendar.google_id}: #{e.message}"
    ensure
      calendar.finish_sync!
    end
  end

  private

  # sync or create the calendar in the local database
  def sync_calendar(google_calendar, user)
    user.calendars.find_or_create_by(google_id: google_calendar.id) do |cal|
      cal.name = google_calendar.summary
    end
  end

  # sync the events of a calendar (add, update, delete)
  def sync_events(service, calendar)
    events = service.list_events(calendar.google_id, single_events: true, order_by: "startTime", time_min: Time.now.iso8601).items

    google_event_ids = events.map(&:id)

    # delete orphaned events (events not in Google Calendar)
    calendar.events.where.not(google_id: google_event_ids).destroy_all

    # add or update events in the local database
    events.each do |event|
      local_event = calendar.events.find_or_initialize_by(google_id: event.id)
      local_event.update(
        summary: event.summary,
        description: event.description,
        start_time: event.start.date_time || event.start.date,
        end_time: event.end.date_time || event.end.date
      )
      local_event
    end
  end
end
