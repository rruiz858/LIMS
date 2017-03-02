class AddFreezeThawCountAndSmilesToBottles < ActiveRecord::Migration
  def change
    add_column :bottles, :freeze_thaw_count, :integer
    add_column :bottles, :smiles, :string
  end
end
