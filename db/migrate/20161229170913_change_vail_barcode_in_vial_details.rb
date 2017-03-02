class ChangeVailBarcodeInVialDetails < ActiveRecord::Migration
  def up
    change_column :vial_details, :aliquot_vial_barcode, :string
  end

  def down
    change_column :vial_details, :aliquot_vial_barcode, :integer
  end
end
