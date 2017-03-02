class AddMappedOtherToPlateDetails < ActiveRecord::Migration
  def change
    add_column :plate_details, :mapped_other, :boolean, default: false
  end
end
