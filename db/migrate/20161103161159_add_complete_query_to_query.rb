class AddCompleteQueryToQuery < ActiveRecord::Migration
  def change
    add_column :queries, :complete_query, :string
  end
end
