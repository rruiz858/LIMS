class AddAmountToShipmentFiles < ActiveRecord::Migration
  def change
    add_column :shipment_files, :amount, :integer
  end
end
