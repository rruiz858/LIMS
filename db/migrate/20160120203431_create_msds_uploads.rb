class CreateMsdsUploads < ActiveRecord::Migration
  def change
    create_table :msds_uploads do |t|
      t.text :msds_pdfs, array: true
      t.timestamps null: false
    end
  end
end
