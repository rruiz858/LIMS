class CreateSourceSubstanceOrderControls < ActiveRecord::Migration
  def change
    create_table :controls do |t|
      t.belongs_to :order, index: true, foreign_key: true
      t.integer :source_substance_id, index: true
      t.boolean :controls, default: false

      t.timestamps null: false
    end
  end
end
