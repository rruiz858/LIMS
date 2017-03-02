class CreateComits < ActiveRecord::Migration
  def change
    create_table :comits do |t|
      t.string :filename
      t.string :file_url
      t.integer :file_kilobytes
      t.integer :file_record_count
      t.integer :added_by_user_id

      t.timestamps null: false
    end
  end
end
