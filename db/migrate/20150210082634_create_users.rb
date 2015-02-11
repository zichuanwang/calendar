class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, index: true
      t.string :refresh_token
      t.string :access_token
      t.string :calendar_list_sync_token
      t.timestamps null: false
    end
  end
end
