class AddRecordErrorToCoaSummaryFile < ActiveRecord::Migration
  def change
    add_column :coa_summary_files, :record_error, :integer
  end
end
