class CreateCoaUploads < ActiveRecord::Migration
  def change
    create_table :coa_uploads do |t|
      t.text :coa_pdfs, array: true
      t.timestamps null: false
    end
  end
end
