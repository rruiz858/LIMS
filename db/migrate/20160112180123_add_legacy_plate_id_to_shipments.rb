class AddLegacyPlateIdToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :legacy_plate_id, :string
  end
end
