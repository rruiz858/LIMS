class CreateVialDetails < ActiveRecord::Migration
  def change
    create_table :vial_details do |t|
      t.string :ism
      t.string :sample_id
      t.string :structure_id
      t.decimal :structure_real_amw
      t.string :sample_supplier
      t.string :supplier_structure_id
      t.string :aliquot_plate_barcode
      t.integer :aliquot_well_id
      t.integer :aliquot_vial_barcode
      t.decimal :aliquot_amount
      t.string :aliquot_amount_unit
      t.string :sample_appearance
      t.string :structure_name
      t.string :cas_regno
      t.string :supplier_sample_id
      t.string :aliquot_date
      t.string :solubilized_barcode
      t.string :lts_barcode
      t.string :source_barcode
      t.decimal :purity
      t.string :purity_method

      t.timestamps null: false
    end
  end
end
