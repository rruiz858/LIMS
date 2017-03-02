class AddWellIdToShipmentsBottles < ActiveRecord::Migration
  def change
    add_column :shipments_bottles, :well_id, :string
  end
end
