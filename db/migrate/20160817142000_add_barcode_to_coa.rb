class AddBarcodeToCoa < ActiveRecord::Migration
  def change
    add_column :coas, :barcode, :string
  end
end
