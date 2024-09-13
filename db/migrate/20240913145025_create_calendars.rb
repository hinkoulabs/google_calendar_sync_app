class CreateCalendars < ActiveRecord::Migration[7.2]
  def change
    create_table :calendars do |t|
      t.string :name
      t.string :google_id

      t.timestamps
    end
  end
end
