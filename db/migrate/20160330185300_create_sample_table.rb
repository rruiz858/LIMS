class CreateSampleTable < ActiveRecord::Migration
  def change
    create_table :samples do |t|
      t.string :source_barcode, index: true
      t.integer :gsid, index: true
      t.text :notes
      t.string :data_type
      t.timestamps null: false
    end
  end
end
