class AddCommercialSourceToCoaSummary < ActiveRecord::Migration
  def change
    add_column :coa_summaries, :commercial_source, :string
  end
end
