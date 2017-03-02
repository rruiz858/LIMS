class AddTransactionTimeToTables < ActiveRecord::Migration
  def change
    add_column :shipment_files, :transaction_time, :timestamp
    add_column :vial_details, :transaction_time, :timestamp
    add_column :plate_details, :transaction_time, :timestamp
    add_index :shipment_files, :transaction_time
    add_index :vial_details, :transaction_time
    add_index :plate_details, :transaction_time
  end
end
