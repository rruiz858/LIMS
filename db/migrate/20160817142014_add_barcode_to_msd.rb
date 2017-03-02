class AddBarcodeToMsd < ActiveRecord::Migration
  def change
    add_column :msds, :barcode, :string
  end
end
