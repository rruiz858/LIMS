class DropDsstoxChemicalLists < ActiveRecord::Migration
  def change
    drop_table :dsstox_chemical_lists do |t|
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
  end
end
