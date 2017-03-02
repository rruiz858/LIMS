class AddAmountUnitToShipmentFiles < ActiveRecord::Migration
  def change
    add_column :shipment_files, :amount_unit, :string
  end
end
