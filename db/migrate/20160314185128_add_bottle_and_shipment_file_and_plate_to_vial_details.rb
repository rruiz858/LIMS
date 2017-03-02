class AddBottleAndShipmentFileAndPlateToVialDetails < ActiveRecord::Migration
  def change
    add_reference :vial_details, :bottle, index: true, foreign_key: true
    add_reference :vial_details, :shipment_file, index: true, foreign_key: true
  end
end
