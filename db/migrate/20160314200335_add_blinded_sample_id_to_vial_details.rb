class AddBlindedSampleIdToVialDetails < ActiveRecord::Migration
  def change
    add_column :vial_details, :blinded_sample_id, :string
  end
end
