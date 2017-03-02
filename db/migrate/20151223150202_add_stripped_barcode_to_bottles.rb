class AddStrippedBarcodeToBottles < ActiveRecord::Migration
  def change
    add_column :bottles, :stripped_barcode, :string
  end
end
