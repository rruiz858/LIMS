class AddQcNotesToSourceGenericSubstances < ActiveRecord::Migration
  if Rails.env.test?
    def change
      add_column :source_generic_substances, :qc_notes, :string
      end
    end
  end

