class AddUserToCoaSummary < ActiveRecord::Migration
  def change
    add_reference :coa_summaries, :user, index: true, foreign_key: true
  end
end
