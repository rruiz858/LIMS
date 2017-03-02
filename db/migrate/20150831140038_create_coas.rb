class CreateCoas < ActiveRecord::Migration
  def change
    create_table :coas do |t|
      t.string :filename
      t.string :file_url
      t.integer :file_kilobytes
      t.references :user, index: true, foreign_key: true
      t.belongs_to :bottle, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
