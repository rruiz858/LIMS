class CreateDsstoxSourceGenericSubstance < ActiveRecord::Migration
  def change
    create_table :source_generic_substances do |t|
     t.integer :fk_source_substance_id, index: true
     t.integer :fk_generic_substance_id,  index: true
     t.string :created_by
     t.string :updated_by
     t.timestamps null: false
    end
  end
end
