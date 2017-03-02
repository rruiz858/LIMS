require 'test_helper'

class CoaSummaryTest < ActiveSupport::TestCase
  setup do
    @coa_summary = coa_summaries(:one)
    @coa_summary_2 = coa_summaries(:five)
    @generic_substance = generic_substances(:one)
    @generic_substance2 = generic_substances(:three)
    @bottle = bottles(:two)
  end

  test "should not save a coa_summary during an update if GSID is empty" do
    coa_summary = CoaSummary.new
    coa_summary.update_attributes(:gsid => "")
    assert_not coa_summary.save
  end

  test "should test the added scopes for curated and uncurated records" do
    assert CoaSummary.curated.count == 8 , "Curated scope is not working accordingly"
    assert CoaSummary.uncurated.count == 6, "Uncurated scope is not working properly"

  end

  test "should test the get_gsid class method" do
   CoaSummary.get_gsid(@coa_summary).rows.each do |gsid, casrn, name|
      assert_equal @generic_substance.id, gsid
      assert_equal @generic_substance.casrn, casrn
      assert_equal @generic_substance.preferred_name, name
   end
   CoaSummary.get_gsid(@coa_summary_2).rows.each do |gsid, casrn, name|
     assert_equal  @generic_substance2.id, gsid
     assert_equal @bottle.cas, casrn
     assert_equal @bottle.compound_name, name
   end
  end

end
