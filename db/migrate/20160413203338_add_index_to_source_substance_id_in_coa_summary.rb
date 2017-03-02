class AddIndexToSourceSubstanceIdInCoaSummary < ActiveRecord::Migration
  def change
    add_index :coa_summaries, :source_substance_id
  end
end
