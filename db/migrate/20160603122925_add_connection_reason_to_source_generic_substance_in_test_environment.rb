class AddConnectionReasonToSourceGenericSubstanceInTestEnvironment < ActiveRecord::Migration
  if Rails.env.test?
    def change
      add_column :source_generic_substances, :curator_validated, :integer
    end
  end
end
