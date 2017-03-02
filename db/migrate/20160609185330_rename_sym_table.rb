class RenameSymTable < ActiveRecord::Migration
  if Rails.env.test?
    def change
      rename_table(:synonym_mv, :synonym_mvs)
    end
  end
end
