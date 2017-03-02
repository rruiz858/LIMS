class AddSolventToShipmentFiles < ActiveRecord::Migration
  def change
    add_column :shipment_files, :solvent, :string
  end
end
