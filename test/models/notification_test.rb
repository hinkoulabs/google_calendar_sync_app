require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  context 'validations' do
    should validate_presence_of(:message)
  end
end
