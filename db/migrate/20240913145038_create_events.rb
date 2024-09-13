class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.string :summary
      t.text :description
      t.datetime :start_time
      t.datetime :end_time
      t.references :calendar, null: false, foreign_key: true
      t.string :google_id

      t.timestamps
    end
  end
end
