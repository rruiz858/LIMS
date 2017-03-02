class AddBarcodeToShipmentsbottles < ActiveRecord::Migration
  def change
    add_column :shipments_bottles, :barcode, :string
  end
end
