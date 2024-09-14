require "test_helper"

class CalendarTest < ActiveSupport::TestCase
  test "should destroy associated events when destroyed" do
    calendar = calendars(:one)

    assert_difference "Event.count", -1 do
      calendar.destroy
    end
  end
end
