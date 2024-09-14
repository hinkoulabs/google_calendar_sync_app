require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  include SignInHelper

  test "should get index" do
    get root_path
    assert_response :success
    assert_select 'h1', text: "Welcome to the Google Calendar Sync App"
  end

  test "should redirect to calendars if user is logged in" do
    user = users(:one)
    sign_in_as(user)

    get root_path
    assert_redirected_to calendars_path
  end
end
