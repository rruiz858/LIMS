class AddIndexToTablesInTest < ActiveRecord::Migration
  if Rails.env.test?
    def change
       add_index :synonym_mv, :fk_generic_substance_id
       add_index :synonym_mv, :identifier
       add_index :synonym_mv, :synonym_type
       add_index :synonym_mv, :rank
       add_index :source_substance_identifiers, :fk_source_substance_id
       add_index :source_substance_identifiers, :identifier
       add_index :source_substance_identifiers, :identifier_type
    end
  end
end
