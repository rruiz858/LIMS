class AddSynonymMvToTestEnvironment < ActiveRecord::Migration
  def change
    if Rails.env.test?
      def change
        create_table :synonym_mv do |t|
          t.integer :fk_generic_substance_id
          t.string :identifier
          t.string :synonym_type
          t.integer :rank
          t.timestamps null: false
        end
      end
    end
  end
end
