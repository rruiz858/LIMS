class AddVialToShipmentFile < ActiveRecord::Migration
  def change
    add_column :shipment_files, :vial, :boolean, :default => false
  end
end
