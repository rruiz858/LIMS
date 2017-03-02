class AddIsValidDescriptionToCoaSummaryFiles < ActiveRecord::Migration
  def change
    add_column :coa_summary_files, :is_valid, :boolean
    add_column :coa_summary_files, :description, :text
  end
end
