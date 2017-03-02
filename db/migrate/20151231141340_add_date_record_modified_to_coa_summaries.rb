class AddDateRecordModifiedToCoaSummaries < ActiveRecord::Migration
  def change
    add_column :coa_summaries, :date_record_added, :string
    add_column :coa_summaries, :date_record_modified, :string
  end
end
