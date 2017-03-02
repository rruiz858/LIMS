class ChangePrecisionOfAliquotAmount < ActiveRecord::Migration
  def change
    change_column :vial_details, :aliquot_amount, :decimal, :precision => 16, :scale =>2
  end
end
