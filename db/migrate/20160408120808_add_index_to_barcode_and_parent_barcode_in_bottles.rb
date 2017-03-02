class AddIndexToBarcodeAndParentBarcodeInBottles < ActiveRecord::Migration
  def change
    add_index :bottles, :barcode
    add_index :bottles, :barcode_parent
  end
end
