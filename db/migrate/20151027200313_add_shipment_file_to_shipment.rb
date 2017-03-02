class AddShipmentFileToShipment < ActiveRecord::Migration
  def change
    add_reference :shipments, :shipment_file, index: true, foreign_key: true
  end
end
