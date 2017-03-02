class AddUpdatedByToSourceSubstance < ActiveRecord::Migration
  def change
    add_column :source_substances, :updated_by, :string
  end
end
