require 'test_helper'

class CalendarsControllerTest < ActionDispatch::IntegrationTest
  include SignInHelper

  test "should get index" do
    user = users(:one)
    sign_in_as(user)

    get calendars_path
    assert_response :success
    assert_select 'h1', text: "Calendars [test@gmail.com]"
  end

  test "should redirect to root_path on index if user is not logged in" do
    get calendars_path
    assert_redirected_to root_path
  end

  test "should get sync" do
    user = users(:one)
    sign_in_as(user) do
      SyncCalendarsJob.expects(:perform_later).with(user.id).twice
    end

    post sync_calendars_path
    assert_redirected_to calendars_path
    assert_equal "Calendars syncing has been started.", flash[:notice]
  end

  test "should redirect to root_path on sync if user is not logged in" do
    post sync_calendars_path
    assert_redirected_to root_path
  end
end
