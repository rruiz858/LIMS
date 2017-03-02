class AddVendorToShipmentFile < ActiveRecord::Migration
  def change
    add_reference :shipment_files, :vendor, index: true, foreign_key: true
  end
end
