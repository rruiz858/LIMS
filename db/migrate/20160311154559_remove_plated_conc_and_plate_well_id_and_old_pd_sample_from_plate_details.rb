class RemovePlatedConcAndPlateWellIdAndOldPdSampleFromPlateDetails < ActiveRecord::Migration
  def change
    remove_columns :plate_details, :plated_conc, :plated_well_id, :old_legacy_sample
  end
end
