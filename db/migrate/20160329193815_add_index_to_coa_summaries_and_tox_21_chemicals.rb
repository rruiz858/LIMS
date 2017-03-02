class AddIndexToCoaSummariesAndTox21Chemicals < ActiveRecord::Migration
  def change
    add_index :tox_21_chemicals, :t_tox21_id, unique: true
    add_index :tox_21_chemicals,:t_original_sample_id
    add_index :coa_summaries, :bottle_barcode
  end
end
