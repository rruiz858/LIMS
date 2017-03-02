class AddIndexToPlateDetails < ActiveRecord::Migration
  def change
    add_index :plate_details, :blinded_sample_id
  end
end
