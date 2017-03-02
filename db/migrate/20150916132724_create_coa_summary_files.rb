class CreateCoaSummaryFiles < ActiveRecord::Migration
  def change
    create_table :coa_summary_files do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :filename
      t.string :file_url
      t.integer :file_kilobytes

      t.timestamps null: false
    end
  end
end
