class AddCreatedByToSourceSubstance < ActiveRecord::Migration
  def change
    add_column :source_substances, :created_by, :string
  end
end
