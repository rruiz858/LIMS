class RemoveLegacyPlateIdFromShipments < ActiveRecord::Migration
  def change
    remove_column :shipments, :legacy_plate_id
  end
end
