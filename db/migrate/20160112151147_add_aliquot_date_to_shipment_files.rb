class AddAliquotDateToShipmentFiles < ActiveRecord::Migration
  def change
    add_column :shipment_files, :aliquot_date, :integer
  end
end
