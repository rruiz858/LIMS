class AddStandardReplicateToControls < ActiveRecord::Migration
  def change
    add_column :controls, :standard_replicate, :boolean, :default => false
    add_column :controls, :originally_found_replicate, :boolean, :default => false
  end
end
