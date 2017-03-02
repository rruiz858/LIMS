class RemoveMixtureDetailPlateDetailsAndVialDetails < ActiveRecord::Migration
  def up
    remove_column :vial_details, :mixture_detail
    remove_column :plate_details, :mixture_detail
  end

  def down
    add_column :vial_details, :mixture_detail, :boolean, :default => false
    add_column :plate_details, :mixture_detail, :boolean, :default => false
  end

end
