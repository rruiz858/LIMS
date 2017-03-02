class AddNewTimeStampImplementation < ActiveRecord::Migration
  CREATE_TIMESTAMP = 'DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP'
  UPDATE_TIMESTAMP = 'DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'
  AFFECTED_TABLES = [:activities, :addresses, :bottles, :coas, :coa_summaries, :coa_summary_files,
  :coa_uploads, :comits, :controls, :mentor_postdocs, :msds, :msds_uploads, :order_chemical_lists,
  :order_plate_details, :orders, :order_statuses, :plate_details, :plates, :roles, :samples, :shipment_files,
  :shipments_activities, :task_orders, :users, :users_task_orders, :vendors, :vial_details]

  def self.up
    AFFECTED_TABLES.each do |t|
      add_column(t,:created_at, CREATE_TIMESTAMP )
      add_column(t,:updated_at, UPDATE_TIMESTAMP)
    end
  end
end
