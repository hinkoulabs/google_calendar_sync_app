class AddUniqRestrictions < ActiveRecord::Migration[7.2]
  def change
    add_index :calendars, [:user_id, :google_id], unique: true
    add_index :events, [:calendar_id, :google_id], unique: true
  end
end
