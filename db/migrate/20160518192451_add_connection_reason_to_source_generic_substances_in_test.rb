class AddConnectionReasonToSourceGenericSubstancesInTest < ActiveRecord::Migration
  if Rails.env.test?
    def change
      add_column :source_generic_substances, :connection_reason, :string
    end
  end
end
