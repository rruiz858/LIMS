class RemoveDsstoxGsidFromCoaSummary < ActiveRecord::Migration
  def change
    remove_column :coa_summaries, :dsstox_gsid, :integer
  end
end
