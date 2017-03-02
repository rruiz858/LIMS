class AddLegacyIdToVialDetails < ActiveRecord::Migration
  def change
    add_column :vial_details, :legacy_id, :string
    add_index :vial_details, :legacy_id, unique: true
  end
end
