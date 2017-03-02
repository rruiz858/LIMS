class AddEvotechOrderNumAndEvotechShipmentNumToShipmentFile < ActiveRecord::Migration
  def change
    add_column :shipment_files, :evotech_order_num, :string
    add_column :shipment_files, :evotech_shipment_num, :string
  end
end
