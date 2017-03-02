class AddSourceSubstanceIdToCoaSummary < ActiveRecord::Migration
  def change
    add_column :coa_summaries, :source_substance_id, :integer, index: true
  end
end
