class CreateCoaSummaries < ActiveRecord::Migration
  def change
    create_table :coa_summaries do |t|
      t.string :bottle_barcode
      t.integer :coa_table_entry
      t.string :coa
      t.string :msds
      t.string :inventory_source
      t.string :coa_product_no
      t.string :coa_lot_number
      t.string :coa_chemical_name
      t.string :coa_casrn
      t.integer :coa_molecular_weight
      t.integer :coa_density
      t.string :coa_purity_percentage
      t.string :coa_methods
      t.string :coa_test_date
      t.string :coa_expiration_date
      t.text :msds_cautions
      t.text :coa_review_notes
      t.integer :dsstox_gsid
      t.string :reviewer_initials

      t.timestamps null: false
    end
  end
end
