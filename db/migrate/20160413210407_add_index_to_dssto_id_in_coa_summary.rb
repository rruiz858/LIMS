class AddIndexToDsstoIdInCoaSummary < ActiveRecord::Migration
  def change
    add_index :coa_summaries, :dssto_id
  end
end
