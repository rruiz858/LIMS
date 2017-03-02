class AddOriginalFilenameToShipmentFile < ActiveRecord::Migration
  def change
    add_column :shipment_files, :original_filename, :string
  end
end
