class AddDsstoxTablesToTestEnvironment < ActiveRecord::Migration
  if Rails.env.test?
    def change
      create_table :chemical_lists do |t|
        t.string :list_abbreviation
        t.string :list_name
        t.string :list_description
        t.string :ncct_contact
        t.string :source_contact
        t.string :source_contact_email
        t.string :list_type
        t.string :list_update_mechanism
        t.string :list_accessibility
        t.string :curation_complete
        t.string :source_data_updated_at
        t.string :created_by
        t.string :updated_by
        t.timestamps null: false
      end

      create_table :source_substances do |t|
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

      create_table :generic_substances do |t|
        t.string :dsstox_substance_id
        t.string :casrn
        t.string :preferred_name
        t.string :substance_type
        t.string :qc_level
        t.string :qc_notes
        t.string :qc_notes_private
        t.string :source
        t.string :created_by
        t.string :updated_by
        t.timestamps null: false
      end

      create_table :source_generic_substances do |t|
        t.integer :fk_source_substance_id, index: true
        t.integer :fk_generic_substance_id, index: true
        t.string :created_by
        t.string :updated_by
        t.timestamps null: false
      end

      create_table :generic_substance_compounds do |t|
        t.integer :fk_generic_substance_id, index: true
        t.integer :fk_compound_id, index: true
        t.string :relationship
        t.string :source
        t.string :created_by
        t.string :updated_by
        t.timestamps null: false
      end

      create_table :compounds do |t|
        t.string :dsstox_compound_id
        t.text :smiles
        t.text :inchi
        t.string :mol_formula
        t.integer :mol_weight
        t.string :created_by
        t.string :updated_by
        t.timestamps null: false
      end
    end
  end
end