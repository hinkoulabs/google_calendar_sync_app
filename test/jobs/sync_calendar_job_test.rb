require "test_helper"
require "google/apis/calendar_v3"

class SyncCalendarJobTest < ActiveJob::TestCase
  def mock_google_service(events)
    event_list_mock = stubs("calendar_list_mock")
    event_list_mock.expects(:items).returns(events)
    Google::Apis::CalendarV3::CalendarService.any_instance.expects(:list_events).returns(event_list_mock)
  end

  setup do
    @time = DateTime.new(2024, 1, 1, 10, 0)

    @now = Time.new(2024, 9, 10, 11, 0, 0)

    Time.stubs(:current).returns(@now)
  end

  test "should sync calendar" do
    calendar = calendars(:calendar_without_events)

    calendar.update_attribute(:syncing, true)

    mock_google_service(
      [
        OpenStruct.new(
          id: "id",
          summary: "summary",
          description: "description",
          start: OpenStruct.new(date_time: @time),
          end: OpenStruct.new(date_time: @time)
        )
      ]
    )

    assert_difference("calendar.events.count") do
      assert_no_difference("SyncErrorNotification.count") do
        SyncCalendarJob.perform_now(calendar.id)
      end
    end

    calendar.reload

    assert_record_attributes calendar, syncing: false, synced_at: @now

    assert_record_attributes(
      calendar.events.last,
      google_id: "id",
      summary: "summary",
      description: "description",
      start_time: @time,
      end_time: @time
    )
  end

  test "should sync event for calendar :one (event exists)" do
    event = events(:one)

    calendar = event.calendar

    mock_google_service(
      [
        OpenStruct.new(
          id: event.google_id,
          summary: "summary",
          description: "description",
          start: OpenStruct.new(date_time: @time),
          end: OpenStruct.new(date_time: @time)
        )
      ]
    )

    assert_no_difference([ "calendar.events.count", "SyncErrorNotification.count" ]) do
      SyncCalendarJob.perform_now(event.calendar_id)
    end

    calendar.reload

    assert_record_attributes calendar, syncing: false, synced_at: @now

    event.reload

    assert_record_attributes(
      event,
      google_id: event.google_id,
      summary: "summary",
      description: "description",
      start_time: @time,
      end_time: @time
    )
  end

  test "should sync events for calendar :one (event is deleted on google and 2 new events were added)" do
    event = events(:one)

    calendar = event.calendar

    mock_google_service(
      [
        OpenStruct.new(
          id: "ev111",
          summary: "summary",
          description: "description",
          start: OpenStruct.new(date_time: @time),
          end: OpenStruct.new(date_time: @time)
        ),
        OpenStruct.new(
          id: "ev222",
          summary: "summary 2",
          description: "description 2",
          start: OpenStruct.new(date_time: @time),
          end: OpenStruct.new(date_time: @time)
        )
      ]
    )

    assert_difference("calendar.events.count", 1) do
      assert_no_difference("SyncErrorNotification.count") do
        SyncCalendarJob.perform_now(calendar.id)
      end
    end

    calendar.reload

    assert_record_attributes calendar, syncing: false, synced_at: @now

    assert_nil Event.find_by_id(event.id)

    assert_record_attributes(
      calendar.events.find_by(google_id: "ev111"),
      summary: "summary",
      description: "description",
      start_time: @time,
      end_time: @time
    )

    assert_record_attributes(
      calendar.events.find_by(google_id: "ev222"),
      summary: "summary 2",
      description: "description 2",
      start_time: @time,
      end_time: @time
    )
  end

  test "should handle errors and log sync errors" do
    calendar = calendars(:one)

    # force the mock service to raise an error
    Google::Apis::CalendarV3::CalendarService.any_instance.stubs(:list_events).raises(StandardError, "Google API error")

    assert_difference("SyncErrorNotification.count", 1) do
      assert_no_difference("Event.count") do
        SyncCalendarJob.perform_now(calendar.id)
      end
    end

    calendar.reload

    assert_record_attributes calendar, syncing: false, synced_at: @now

    assert_record_attributes SyncErrorNotification.last, message: "Google API error", user: calendar.user
  end
end
