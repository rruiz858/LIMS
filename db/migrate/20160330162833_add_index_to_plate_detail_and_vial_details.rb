class AddIndexToPlateDetailAndVialDetails < ActiveRecord::Migration
  def change
    add_index :plate_details, :source_barcode
    add_index :vial_details, :source_barcode
  end
end
