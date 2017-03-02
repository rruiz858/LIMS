class ChangeAliquotWellIdFromIntegerToString < ActiveRecord::Migration
  def change
    change_column :vial_details, :aliquot_well_id, :string
  end
end
