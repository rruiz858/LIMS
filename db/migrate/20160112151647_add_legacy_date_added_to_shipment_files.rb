class AddLegacyDateAddedToShipmentFiles < ActiveRecord::Migration
  def change
    add_column :shipment_files, :legacy_date_added, :integer
  end
end
