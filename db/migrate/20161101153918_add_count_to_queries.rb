class AddCountToQueries < ActiveRecord::Migration
  def change
    add_column :queries, :count, :integer
  end
end
