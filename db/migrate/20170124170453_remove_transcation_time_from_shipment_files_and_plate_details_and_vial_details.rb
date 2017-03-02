class RemoveTranscationTimeFromShipmentFilesAndPlateDetailsAndVialDetails < ActiveRecord::Migration
  def up
    remove_column :shipment_files, :transaction_time
    remove_column :vial_details, :transaction_time
    remove_column :plate_details, :transaction_time
  end

  def down
    add_column :shipment_files, :transaction_time, :timestamp
    add_column :vial_details, :transaction_time, :timestamp
    add_column :plate_details, :transaction_time, :timestamp
  end
end
