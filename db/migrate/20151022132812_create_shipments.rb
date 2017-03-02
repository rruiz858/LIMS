class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.string :ism
      t.string :sample_id
      t.string :structure_id
      t.string :structure_real_amw
      t.string :sample_supplier
      t.string :supplier_structure_id
      t.string :aliquot_plate_barcode
      t.string :aliquot_well_id
      t.string :aliquot_solvent
      t.integer :aliquot_conc
      t.string :aliquot_conc_unit
      t.string :aliquot_volume
      t.string :aliquot_volume_unit
      t.string :sample_appearance
      t.string :structure_name
      t.string :cas_regno
      t.string :supplier_sample_id
      t.string :aliquot_date
      t.string :solubilized_barcode
      t.string :lts_barcode
      t.string :source_barcode
      t.references :bottle, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
