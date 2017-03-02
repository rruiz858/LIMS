class AddTaskOrderAndAddressAndConcentrationAndAmountAndOrderConcentrationAndExternalToShipmentFiles < ActiveRecord::Migration
  def change
    add_reference :shipment_files, :task_order, index: true, foreign_key: true
    add_reference :shipment_files, :address, index: true, foreign_key: true
    add_reference :shipment_files, :order_concentration, index: true, foreign_key: true
    add_column :shipment_files, :external, :boolean, default: false
  end
end
