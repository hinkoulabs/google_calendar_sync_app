class AddSyncingToCalendars < ActiveRecord::Migration[7.2]
  def change
    add_column :calendars, :syncing, :boolean
  end
end
