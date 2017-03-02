class CreatePlateType < ActiveRecord::Migration
  def change
    create_table :plate_types do |t|
      t.string :label
      t.integer :numeric_value
    end
  end
end
