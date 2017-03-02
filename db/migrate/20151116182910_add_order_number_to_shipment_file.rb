class AddOrderNumberToShipmentFile < ActiveRecord::Migration
  def change
    add_column :shipment_files, :order_number, :string
  end
end
