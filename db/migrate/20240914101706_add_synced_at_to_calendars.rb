class AddSyncedAtToCalendars < ActiveRecord::Migration[7.2]
  def change
    add_column :calendars, :synced_at, :timestamp
  end
end
