class CreateCals < ActiveRecord::Migration
  def change
    create_table :cals do |t|
      t.string :calendar_id, index: true
      t.integer :user_id, index: true
      t.string :name
      t.string :sync_token
      t.string :foreground_color
      t.string :background_color
      t.timestamps null: false
    end
  end
end
