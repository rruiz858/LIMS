class CreateShipmentsBottles < ActiveRecord::Migration
  def change
    create_table :shipments_bottles do |t|
      t.belongs_to :shipment_file, index: true, foreign_key: true
      t.string :plate_barcode
      t.belongs_to :bottle, index: true, foreign_key: true
      t.integer :concentration
      t.string :concentration_unit
      t.integer :amount
      t.string :amount_unit

      t.timestamps null: false
    end
  end
end
