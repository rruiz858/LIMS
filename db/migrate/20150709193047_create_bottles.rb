class CreateBottles < ActiveRecord::Migration
  def change
    create_table :bottles do |t|
      t.string :barcode_parent
      t.string :barcode
      t.string :status
      t.string :compound_name
      t.string :cas
      t.string :cid
      t.string :vendor
      t.string :vendor_part_number
      t.integer :qty_available_mg
      t.integer :qty_available_ul
      t.integer :concentration_mm
      t.integer :qty_available_umols
      t.string :structure_real_amw
      t.string :sam
      t.string :cpd
      t.string :po_number
      t.string :lot_number
      t.string :form
      t.string :date_record_added
      t.string :solubility_dmso
      t.string :solubitity_details



      t.timestamps null: false
    end
  end
end
