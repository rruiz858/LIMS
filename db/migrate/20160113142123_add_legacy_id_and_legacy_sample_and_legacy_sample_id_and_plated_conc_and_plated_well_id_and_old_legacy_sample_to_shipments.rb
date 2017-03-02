class AddLegacyIdAndLegacySampleAndLegacySampleIdAndPlatedConcAndPlatedWellIdAndOldLegacySampleToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :legacy_id, :string
    add_column :shipments, :legacy_sample, :string
    add_column :shipments, :legacy_sample_id, :string
    add_column :shipments, :plated_conc, :string
    add_column :shipments, :plated_well_id, :string
    add_column :shipments, :old_legacy_sample, :string
  end
end
