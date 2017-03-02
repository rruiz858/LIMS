class AddMixtureDetailsToDetails < ActiveRecord::Migration
  def change
    add_column :plate_details, :mixture_detail, :boolean, :default => false
    add_column :vial_details, :mixture_detail, :boolean, :default => false
  end
end
