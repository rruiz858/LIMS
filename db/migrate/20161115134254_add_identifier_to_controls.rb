class AddIdentifierToControls < ActiveRecord::Migration
  def change
    add_column :controls, :identifier, :string
  end
end
