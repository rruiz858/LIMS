class AddConditionsToQueries < ActiveRecord::Migration
  def change
    add_column :queries, :conditions, :string
  end
end
