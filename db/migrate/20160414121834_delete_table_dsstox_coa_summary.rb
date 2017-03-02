class DeleteTableDsstoxCoaSummary < ActiveRecord::Migration
  def up
    drop_table :dsstox_coa_summaries
  end

  def down
    create_table :dsstox_coa_summaries do |t|
      t.references :coa_summary, index: true, foreign_key: true
      t.references :dssto, primary_key: "gsid"
      t.timestamps null: false
    end
  end
end
