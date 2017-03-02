class AddProcessingToComits < ActiveRecord::Migration
  def change
    add_column :comits, :processing, :boolean, :default => true
  end
end
