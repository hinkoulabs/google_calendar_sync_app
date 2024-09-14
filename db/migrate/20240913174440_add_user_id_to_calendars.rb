class AddUserIdToCalendars < ActiveRecord::Migration[7.2]
  def change
    add_reference :calendars, :user, null: false, foreign_key: true
  end
end
