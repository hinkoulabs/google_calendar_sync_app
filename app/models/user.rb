class User < ApplicationRecord
  has_many :calendars, dependent: :destroy
  has_many :events, through: :calendars

  validates :email, presence: true
  validates :google_id, presence: true
end
