class CreatePlates < ActiveRecord::Migration
  def change
    create_table :plates do |t|
      t.belongs_to :shipment_file, index: true, foreign_key: true
      t.integer :plate_count
      t.timestamps null: false
    end
  end
end
