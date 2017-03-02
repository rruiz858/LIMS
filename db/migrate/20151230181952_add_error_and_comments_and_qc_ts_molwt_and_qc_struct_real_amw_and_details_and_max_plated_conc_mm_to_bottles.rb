class AddErrorAndCommentsAndQcTsMolwtAndQcStructRealAmwAndDetailsAndMaxPlatedConcMmToBottles < ActiveRecord::Migration
  def change
    add_column :bottles, :error, :text
    add_column :bottles, :comments, :text
    add_column :bottles, :qc_ts_molwt, :string
    add_column :bottles, :qc_struct_real_amw, :string
    add_column :bottles, :details, :text
    add_column :bottles, :max_plated_conc_mm, :string
  end
end
