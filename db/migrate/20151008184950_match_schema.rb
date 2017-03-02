class MatchSchema < ActiveRecord::Migration
  def change
    change_table :bottles do |t|
        t.references :coa_summary, index: true
    end
    change_table :comits do |t|
        t.references :user, index: true
        t.string :file_app_name
    end
    add_foreign_key :bottles, :coa_summaries
    add_foreign_key :comits, :users
  end
  def down
    change_table :bottles do |t|
      t.remove :coa_summary_id
    end
    change_table :comits do |t|
      t.remove :user_id
      t.string :file_app_name
    end
    remove_foreign_key :bottles, :coa_summaries
    remove_foreign_key :comits, :users
  end
end
