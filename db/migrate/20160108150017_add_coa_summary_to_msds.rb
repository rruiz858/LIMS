class AddCoaSummaryToMsds < ActiveRecord::Migration
  def change
    add_reference :msds, :coa_summary, index: true, foreign_key: true
  end
end
