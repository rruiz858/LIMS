class RemoveDsstoxTablesFromTestEnvironment < ActiveRecord::Migration
  if Rails.env.test?
    CREATE_TIMESTAMP = 'DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP'
    UPDATE_TIMESTAMP = 'DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'
    def change
      drop_table :source_substances
      create_table :source_substances do |t|
        t.integer :fk_chemical_list_id # foreign key column for mapping to chemical_lists
        t.string :dsstox_record_id #an id for public dissemination created by a trigger based on this table's primary key
        t.string :casrn # the casrn provided from the source
        t.string :name, limit: 1024 # the name provided from the source
        t.string :structure, limit: 1024 # the molecular data provided from the source ()preferably in smiles or inchi format)
        t.string :external_id # an id from the source for the record
        t.string :name_inchikey # the inchikey derived programmatically from the name
        t.string :structure_inchikey # the inchikey derived programmatically from the structure
        t.string :warnings # warnings about a source substance (like 'casrn is invalid', or 'name is duplicated in list')
        t.string :created_by, null: false #the user that created the record
        t.string :updated_by, null: false # the user that last edited the record
        t.column :created_at, CREATE_TIMESTAMP
        t.column :updated_at, UPDATE_TIMESTAMP
        t.index :casrn
        t.index :name, :length => {:name => 255}
        t.index :name_inchikey
        t.index :structure_inchikey
        t.index :updated_at
      end
    end
  end
end