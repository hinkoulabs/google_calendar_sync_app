ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"
require "webmock/minitest"
require "omniauth"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    OmniAuth.config.test_mode = true

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    def assert_record_attributes(record, attrs)
      attrs.each do |attr, value|
        if value.nil?
          assert_nil record.try(attr)
        else
          assert_equal value, record.try(attr)
        end
      end
    end
  end
end

module SignInHelper
  def sign_in_as(user, provider: :google_oauth2)
    OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash.new(
      provider: provider,
      uid: user.google_id,
      info: {
        email: user.email,
        name: user.name
      },
      credentials: {
        token: user.access_token,
        refresh_token: user.refresh_token
      }
    )

    if block_given?
      yield
    else
      SyncCalendarsJob.expects(:perform_later).with(user.id)
    end

    get "/auth/#{provider}/callback"

    assert_redirected_to calendars_path
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end
