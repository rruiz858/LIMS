class AddLegacyPlateIdToPlates < ActiveRecord::Migration
  def change
    add_column :plates, :legacy_plate_id, :string
  end
end
