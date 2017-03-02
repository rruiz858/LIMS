class AddMixtureToShipmentFiles < ActiveRecord::Migration
  def change
    add_column :shipment_files, :mixture, :boolean, default:  false
  end
end
