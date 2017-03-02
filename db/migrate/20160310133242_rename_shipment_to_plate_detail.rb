class RenameShipmentToPlateDetail < ActiveRecord::Migration
  def change
    rename_table :shipments, :plate_details
  end
end
