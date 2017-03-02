class RemoveLegacyPlateIdFromPlates < ActiveRecord::Migration
  def change
    remove_column :plates, :legacy_plate_id
  end
end
