require 'test_helper'
require 'google/apis/calendar_v3'

class SyncCalendarsJobTest < ActiveJob::TestCase
  def mock_google_service(items)
    calendar_list_mock = stubs('calendar_list_mock')
    calendar_list_mock.expects(:items).returns(items)
    Google::Apis::CalendarV3::CalendarService.any_instance.expects(:list_calendar_lists).returns(calendar_list_mock)
  end

  test "should sync calendar for user :user_without_calendars (calendar doesn't exist)" do
    user = users(:user_without_calendars)

    mock_google_service(
      [
        OpenStruct.new(id: 'test@gmail.com', summary: 'Updated test@gmail.com')
      ]
    )

    SyncCalendarJob.expects(:perform_later).once

    assert_difference('Calendar.count') do
      SyncCalendarsJob.perform_now(user.id)
    end

    calendar = Calendar.last

    assert_equal 'test@gmail.com', calendar.google_id
    assert_equal 'Updated test@gmail.com', calendar.name
    assert_equal user, calendar.user
    assert calendar.syncing
  end

  test "should sync calendar for user :one (calendar exists)" do
    calendar = calendars(:one)

    mock_google_service(
      [
        OpenStruct.new(id: calendar.google_id, summary: 'Updated test@gmail.com')
      ]
    )

    SyncCalendarJob.expects(:perform_later).with(calendar.id)

    assert_no_difference('Calendar.count') do
      SyncCalendarsJob.perform_now(calendar.user_id)
    end

    calendar.reload

    assert_equal 'Updated test@gmail.com', calendar.name
    assert calendar.syncing
  end

  test "should sync calendar for user :one (calendar is deleted on google and 2 new calendars were added)" do
    calendar = calendars(:one)

    mock_google_service(
      [
        OpenStruct.new(id: 'new_cal1', summary: 'Holidays'),
        OpenStruct.new(id: 'new_cal2', summary: 'New Calendar')
      ]
    )

    SyncCalendarJob.expects(:perform_later).times(2)

    assert_difference('Calendar.count', 1) do
      SyncCalendarsJob.perform_now(calendar.user_id)
    end

    assert_nil Calendar.find_by_id(calendar.id)

    assert_record_attributes Calendar.find_by(google_id: 'new_cal1'), name: 'Holidays', syncing: true
    assert_record_attributes Calendar.find_by(google_id: 'new_cal2'), name: 'New Calendar', syncing: true
  end

  test "should handle errors and log sync errors" do
    calendar = calendars(:one)

    SyncCalendarJob.expects(:perform_later).never

    # force the mock service to raise an error
    Google::Apis::CalendarV3::CalendarService.any_instance.stubs(:list_calendar_lists).raises(StandardError, 'Google API error')

    assert_difference('SyncErrorNotification.count', 1) do
      assert_no_difference('Calendar.syncing.count') do
        SyncCalendarsJob.perform_now(calendar.user_id)
      end
    end

    assert_record_attributes SyncErrorNotification.last, message: 'Google API error', user: calendar.user
  end
end