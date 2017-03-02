class AddCoaSummaryCountToCoaSummaryFile < ActiveRecord::Migration
  def change
    add_column :coa_summary_files, :coa_summary_count, :integer
  end
end
