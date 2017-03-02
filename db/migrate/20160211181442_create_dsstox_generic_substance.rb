class CreateDsstoxGenericSubstance < ActiveRecord::Migration
  def change
    create_table :dsstox_generic_substances do |t|
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
  end
end
