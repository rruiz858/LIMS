class ChangeCoaDensityFromIntegerToString < ActiveRecord::Migration
  def change
    change_column :coa_summaries, :coa_density, :string
  end
end
