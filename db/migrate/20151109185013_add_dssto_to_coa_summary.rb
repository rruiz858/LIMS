class AddDsstoToCoaSummary < ActiveRecord::Migration
  def change
    add_column :coa_summaries, :dssto_id, :integer, index: true

  end
end
