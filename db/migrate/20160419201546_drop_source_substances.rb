class DropSourceSubstances < ActiveRecord::Migration
  def change
    drop_table :source_substances do |t|
      t.integer :fk_chemical_list_id, index: true
      t.string :dsstox_record_id
      t.string :casrn
      t.string :name
      t.string :structure
      t.string :external_id
      t.string :name_inchikey
      t.string :structure_inchikey
      t.string :warnings
      t.string :created_at
      t.string :updated_at
      t.string :bottle_id
      t.string :dtxid
      t.string :sample_id
      t.string :created_by
      t.string :updated_by
      t.timestamps null: false
    end
  end
end
