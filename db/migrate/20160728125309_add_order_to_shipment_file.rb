class AddOrderToShipmentFile < ActiveRecord::Migration
  def change
    add_reference :shipment_files, :order, index: true, foreign_key: true
  end
end
