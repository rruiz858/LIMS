class AddCoaSummaryToCoa < ActiveRecord::Migration
  def change
    add_reference :coas, :coa_summary, index: true, foreign_key: true
  end
end
