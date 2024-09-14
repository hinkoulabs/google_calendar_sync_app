require "test_helper"

class UserTest < ActiveSupport::TestCase
  context 'validations' do
    should validate_presence_of(:email)
    should validate_presence_of(:google_id)
  end
end
