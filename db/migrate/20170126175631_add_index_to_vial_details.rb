class AddIndexToVialDetails < ActiveRecord::Migration
  def change
    add_index :vial_details, :blinded_sample_id
  end
end
