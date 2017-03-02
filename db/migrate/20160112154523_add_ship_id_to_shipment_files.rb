class AddShipIdToShipmentFiles < ActiveRecord::Migration
  def change
    add_column :shipment_files, :ship_id, :string
  end
end
