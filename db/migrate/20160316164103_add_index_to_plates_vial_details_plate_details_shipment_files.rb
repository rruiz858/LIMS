class AddIndexToPlatesVialDetailsPlateDetailsShipmentFiles < ActiveRecord::Migration
  def change
    add_index :plates, :aliquot_plate_barcode
    add_index :plates, :ship_id
    add_index :plate_details, :aliquot_plate_barcode
    add_index :vial_details, :aliquot_plate_barcode
    add_index :shipment_files, :ship_id
  end
end
