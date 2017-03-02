class AddPlateDetailToShipmentFile < ActiveRecord::Migration
  def change
    add_column :shipment_files, :plate_detail, :string
  end
end
