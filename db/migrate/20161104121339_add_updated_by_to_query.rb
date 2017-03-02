class AddUpdatedByToQuery < ActiveRecord::Migration
  def change
    add_column :queries, :updated_by, :string
  end
end
