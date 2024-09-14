class Calendar < ApplicationRecord
  belongs_to :user
  has_many :events, dependent: :destroy

  scope :syncing, -> { where(syncing: true) }

  validates :google_id, presence: true, uniqueness: { scope: :user_id }

  # broadcast on calendar creation to the current user's channel
  after_create_commit do
    broadcast_append_to user, target: "user_calendars_list_#{user.id}", partial: "calendars/calendar", locals: { calendar: self }

    broadcast_replace_to user, target: "no_calendars_message", content: ""
  end

  # broadcast on calendar update to the current user's channel
  after_update_commit do
    broadcast_replace_to user, target: "calendar_#{self.id}", partial: "calendars/calendar", locals: { calendar: self }
  end

  # broadcast on calendar deletion to the current user's channel
  after_destroy_commit do
    broadcast_remove_to user, target: "calendar_#{self.id}"

    if user.calendars.empty?
      broadcast_replace_to user, target: "no_calendars_message", partial: "calendars/no_calendars"
    end
  end

  def start_sync!
    update(syncing: true)
  end

  def finish_sync!
    update(syncing: false, synced_at: Time.current)
  end
end
