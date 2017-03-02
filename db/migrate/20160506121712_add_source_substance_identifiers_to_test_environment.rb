class AddSourceSubstanceIdentifiersToTestEnvironment < ActiveRecord::Migration
  if Rails.env.test?
    def change
      create_table :source_substance_identifiers do |t|
        t.integer :fk_source_substance_id
        t.string :identifier
        t.string :identifier_type
        t.integer :fk_source_substance_identifier_parent
        t.string :created_by
        t.string :updated_by
        t.timestamps null: false
      end
    end
  end
end
