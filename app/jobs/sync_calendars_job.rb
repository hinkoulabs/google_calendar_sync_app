class SyncCalendarsJob < GoogleCalendarJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)

    begin
      service = init_google_service(user)
      calendar_list = service.list_calendar_lists.items

      google_calendar_ids = calendar_list.map(&:id)

      # delete any local calendars not present in Google Calendar
      delete_orphaned_calendars(user, google_calendar_ids)

      # schedule jobs to sync each calendar
      calendar_list.each do |calendar|
        local_calendar = user.calendars.find_or_create_by(google_id: calendar.id)
        local_calendar.update!(name: calendar.summary)

        # Start syncing the calendar
        local_calendar.start_sync!

        SyncCalendarJob.perform_later(local_calendar.id)
      end
    rescue StandardError => e
      # create sync notification for the user when the sync fails
      SyncErrorNotification.create(user: user, message: e.message)
      # log the error
      Rails.logger.error "error syncing calendars for user ##{user.id}: #{e.message}"
    end
  end

  private

  def delete_orphaned_calendars(user, google_calendar_ids)
    user.calendars.where.not(google_id: google_calendar_ids).destroy_all
  end
end
