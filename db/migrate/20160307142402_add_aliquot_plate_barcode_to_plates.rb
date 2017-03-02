class AddAliquotPlateBarcodeToPlates < ActiveRecord::Migration
  def change
    add_column :plates, :aliquot_plate_barcode, :string
  end
end
