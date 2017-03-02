class AddMappedOtherToVialDetails < ActiveRecord::Migration
  def change
    add_column :vial_details, :mapped_other, :boolean, default: false
  end
end
