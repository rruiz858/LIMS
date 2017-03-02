class AddStatusToShipmentFiles < ActiveRecord::Migration
  def change
    add_column :shipment_files, :status, :string, default: 'finalized'
  end
end
