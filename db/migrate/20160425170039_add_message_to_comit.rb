class AddMessageToComit < ActiveRecord::Migration
  def change
    add_column :comits, :description, :text
  end
end
