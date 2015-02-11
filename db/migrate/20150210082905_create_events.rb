class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.string :event_id, index: true
      t.text :description
      t.integer :cal_id, index: true
      t.integer :user_id, index: true
      t.string :url
      t.datetime :start_time
      t.datetime :end_time
      t.timestamps null: false
    end
  end
end
