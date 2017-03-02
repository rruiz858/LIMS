class AddMissingAttributesToShipmentFiles < ActiveRecord::Migration
  def change
    add_column :shipment_files, :chemical_set, :string
    add_column :shipment_files, :e_ship_num_change, :integer
    add_column :shipment_files, :target_conc_mm, :integer
    add_column :shipment_files, :shipped_date, :integer
    add_column :shipment_files, :asid, :integer
    add_column :shipment_files, :asnm, :string
    add_column :shipment_files, :use_disposition, :string
    add_column :shipment_files, :plate_set_count, :integer
    add_column :shipment_files, :plate_set, :integer
  end
end
