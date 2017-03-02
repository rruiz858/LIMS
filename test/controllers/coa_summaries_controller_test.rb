require 'test_helper'

class CoaSummariesControllerTest < ActionController::TestCase
  setup do
    login_chemadmin
    @coa_summary = coa_summaries(:one)
    @coa_summary_no_pdfs = coa_summaries(:two)
    @gsid = generic_substances(:one)
    @user = users(:superadmin)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:coa_summaries)
  end

  test "should show coa_summary and should show links to coa and msds" do
    xhr :get, :show, id: @coa_summary, format: :js
    assert_response :success
    assert_select 'li.pdfs-class', {:count => 2}
  end

  test "should not show coa or msds if the coa summary does not have them as children" do
    xhr :get, :show, id: @coa_summary_no_pdfs, format: :js
    assert_response :success
    assert_select 'li.pdfs-class', {:count => 0}
  end

  test "should test the override show_action" do
    xhr :get, :override_show, id: @coa_summary.id, format: :js
    assert_response :success
  end

  test "should test the uncurated_counts action" do
    xhr :get, :uncurated_counts, format: :json
    assert_response :success
    assert_not_nil response.body
    json_hash = JSON.parse(response.body)
    assert_equal json_hash['name_other'], 1, "Uncurated count for the name_other matched type is incorrect"
  end


  test "should test the overall uncurated_count for all coa summaries " do
    count = CoaSummary.uncurated.count
    xhr :get, :total_uncurated_count, format: :json
    assert_response :success
    assert_not_nil response.body
    json_hash = JSON.parse(response.body)
    assert_equal json_hash['uncurated_count'], count, "Uncurated count for all coa summaries is incorrect"
  end


  test "should test the overide gsid action" do
    gsid = generic_substances(:one).id
    four = coa_summaries(:four)
    xhr :post, :override_gsid, id: four.id, gsid: gsid, comment: 'This is a ChemTrack Validated Record', format: :js
    updated_coa = CoaSummary.find(four.id)
    updated_mapping = updated_coa.source_substance.source_generic_substance
    assert_equal updated_coa.gsid, gsid
    assert_equal updated_mapping.qc_notes, 'This is a ChemTrack Validated Record'
    assert_equal updated_mapping.curator_validated, 1
    assert_response :success
  end

end
