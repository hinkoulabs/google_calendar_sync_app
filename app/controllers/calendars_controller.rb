require 'google/apis/calendar_v3'

class CalendarsController < ApplicationController
  before_action :authenticate_user

  def index
    @calendars = Calendar.all
  end

  def sync
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = google_auth

    calendar_list = service.list_calendar_lists

    calendar_list.items.each do |calendar|
      local_calendar = Calendar.find_or_create_by(google_id: calendar.id) do |cal|
        cal.name = calendar.summary
      end

      sync_events(service, local_calendar)
    end

    redirect_to calendars_path, notice: 'Calendars and events synced successfully.'
  end

  private

  def sync_events(service, calendar)
    # Fetch events from the Google Calendar
    events = service.list_events(calendar.google_id, single_events: true, order_by: 'startTime', time_min: Time.now.iso8601)

    # Sync each event into the local database
    events.items.each do |event|
      local_event = Event.find_or_initialize_by(google_id: event.id)

      local_event.update(
        summary: event.summary,
        description: event.description,
        start_time: event.start.date_time || event.start.date, # Some events only have a date
        end_time: event.end.date_time || event.end.date,
        calendar: calendar
      )
    end
  end
end