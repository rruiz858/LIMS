require 'test_helper'

class CoaSummaryFilesControllerTest < ActionController::TestCase
  setup do
    login_chemadmin
    @coa_summary_file = coa_summary_files(:one)
  end

  test "should upload and create coa_summary_file record" do
    coa_summary_file = '/files/coa_summaries/Coa_summary_file_same_barcode.xls'
    file = fixture_file_upload(coa_summary_file, 'application/excel')
    assert_difference('CoaSummaryFile.count') do
      post :create, coa_summary_file: {:file_url => file, file_kilobytes: @coa_summary_file.file_kilobytes, filename: @coa_summary_file.filename}
    end
    assert_redirected_to coa_summaries_url
  end

  test "should create a new coa_summary record from a coa_summary_file importation" do
    #barcode in file is not found in fixture, thus a new record in the coa_summary table is added
    coa_summary_file = '/files/coa_summaries/Coa_summary_file_same_barcode.xls'
    file = fixture_file_upload(coa_summary_file, 'application/excel')
    assert_difference('CoaSummary.count', 1) do
      post :create, coa_summary_file: {:file_url => file, file_kilobytes: @coa_summary_file.file_kilobytes, filename: @coa_summary_file.filename}
    end
    assert_redirected_to coa_summaries_url
  end

  test "should create a coa_summary with a casrn and name from the excel file if both fields are present " do
    coa_summary_file = '/files/coa_summaries/Coa_summary_file_same_barcode.xls'
    file = fixture_file_upload(coa_summary_file, 'application/excel')
    post :create, coa_summary_file: {:file_url => file}
    @coa_summary = CoaSummary.last
    assert_equal @coa_summary.coa_casrn, "25013-16-5"
    assert_equal @coa_summary.coa_chemical_name, "Butylated hydroxyanisole,96%"
  end

  test "should update a coa_summary record from a coa_summary_file importation" do
    #barcode in file is not found in fixture, thus a new record in the coa_summary table is added
    coa_summary_file = '/files/coa_summaries/Coa_summary_update.xls'
    file = fixture_file_upload(coa_summary_file, 'application/excel')
    post :create, coa_summary_file: {:file_url => file, file_kilobytes: @coa_summary_file.file_kilobytes, filename: @coa_summary_file.filename}
    assert_equal "MyString", coa_summaries(:two).coa_lot_number
  end

  test "should update the coa_summary_id from nil to an integer of a bottle in fixtures if a coa summary with the same barcode is updated" do
    coa_summary_file = '/files/coa_summaries/Coa_summary_file_same_barcode.xls'
    file = fixture_file_upload(coa_summary_file, 'application/excel')
    post :create, coa_summary_file: {:file_url => file}
    @coa_summary = CoaSummary.last
    @bottle = Bottle.find_by_coa_summary_id(@coa_summary.id)
    assert_equal = @bottle.stripped_barcode, @coa_summary.bottle_barcode
    assert_equal @coa_summary.id, bottles(:ten).coa_summary_id, "Coa_Summary_id for bottle was not updated"
  end

  test "should find missing casrn based on the name located in bottles when uploading a Coa Summary File" do
    coa_summary_file = '/files/coa_summaries/Coa_summary_file_missing_cas.xls'
    file = fixture_file_upload(coa_summary_file, 'application/excel')
    post :create, coa_summary_file: {:file_url => file}
    @coa_summary = CoaSummary.last
    assert_equal @coa_summary.coa_casrn, "70-00-6"
  end

  test "should update the coa_summary_id of a bottle depending on if another bottle has the same barcode_parent" do
    coa_summary_file = '/files/coa_summaries/Coa_summary_file_same_barcode_and_no_name.xls'
    file = fixture_file_upload(coa_summary_file, 'application/excel')
    post :create, coa_summary_file: {:file_url => file}
    @coa_summary = CoaSummary.last
    assert_equal bottles(:eleven).coa_summary_id, bottles(:twelve).coa_summary.id, "Coa_Summary_id for bottle was not updated"
  end


  test "Bottle without coa_summary_id should be updated if other bottle exists with same vendor, cpd, and lot_number has a coa_summary_id" do
    coa_summary_file = '/files/coa_summaries/Coa_summary_file_same_barcode_and_no_name.xls'
    file = fixture_file_upload(coa_summary_file, 'application/excel')
    post :create, coa_summary_file: {:file_url => file}
    assert_equal bottles(:thirteen).coa_summary_id, bottles(:twelve).coa_summary_id
  end

  test "Bottle without coa_summary_id and no lot number should be updated if other bottle exists with same cid, sam, cpd, an no lot number" do
    coa_summary_file = '/files/coa_summaries/Coa_test_no_lot_number.xls'
    file = fixture_file_upload(coa_summary_file, 'application/excel')
    post :create, coa_summary_file: {:file_url => file}
    assert_equal bottles(:six).coa_summary, bottles(:seven).coa_summary
  end

  test "should destroy coa_summary_file" do
    assert_difference('CoaSummaryFile.count', -1) do
      delete :destroy, id: @coa_summary_file
    end
    assert_redirected_to coa_summaries_path
  end


  test "should test the carn_name match type" do
    coa_summary_file = '/files/MatchTypes/CoaSummaryCasrnName.xls'
    file = fixture_file_upload(coa_summary_file, 'application/excel')
    assert_difference('CoaSummaryFile.count') do
      post :create, coa_summary_file: {:file_url => file, file_kilobytes: @coa_summary_file.file_kilobytes, filename: @coa_summary_file.filename}
    end
    @connnection_reason = SourceGenericSubstance.last.connection_reason
    assert_match "MATCHED BY CASRN AND NAME", @connnection_reason
    assert_redirected_to coa_summaries_url
  end


  test "should test the name_other match type" do
    coa_summary_file = '/files/MatchTypes/CoaSummaryNameMartchedOther.xls'
    file = fixture_file_upload(coa_summary_file, 'application/excel')
    assert_difference('CoaSummaryFile.count') do
      post :create, coa_summary_file: {:file_url => file, file_kilobytes: @coa_summary_file.file_kilobytes, filename: @coa_summary_file.filename}
    end
    @connnection_reason = SourceGenericSubstance.last.connection_reason
    assert_match "MATCHED CASRN, NAME MATCHED OTHER", @connnection_reason
    assert_redirected_to coa_summaries_url
  end

  test "should test the casrn match type" do
    coa_summary_file = '/files/MatchTypes/CoaSummaryCASRNMartched.xls'
    file = fixture_file_upload(coa_summary_file, 'application/excel')
    assert_difference('CoaSummaryFile.count') do
      post :create, coa_summary_file: {:file_url => file, file_kilobytes: @coa_summary_file.file_kilobytes, filename: @coa_summary_file.filename}
    end
    @connnection_reason = SourceGenericSubstance.last.connection_reason
    assert_match "MATCHED CASRN", @connnection_reason
    assert_redirected_to coa_summaries_url
  end

  test "should test the no hits match type" do
    coa_summary_file = '/files/MatchTypes/CoaSummaryNoHits.xls'
    file = fixture_file_upload(coa_summary_file, 'application/excel')
    assert_difference('CoaSummaryFile.count') do
      post :create, coa_summary_file: {:file_url => file, file_kilobytes: @coa_summary_file.file_kilobytes, filename: @coa_summary_file.filename}
    end
    @connnection_reason = SourceGenericSubstance.last.connection_reason
    assert_match "NO HIT", @connnection_reason
    assert_redirected_to coa_summaries_url
  end

  test "should indicate that the coa_summary_file is invalid because of duplicate records" do
    excel_filename = '/files/coa_summaries/COA_Summary_Duplicate.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    assert_difference('CoaSummaryFile.count', 1) do
      post :create, coa_summary_file: {:file_url => file, file_kilobytes: @coa_summary_file.file_kilobytes, filename: @coa_summary_file.filename}
    end
    coa_summary_file = CoaSummaryFile.last
    assert_equal coa_summary_file.is_valid, false
  end

  test "should indicate that coa_summary_file is invalid because coa_summary already exists in table" do
    excel_filename = '/files/coa_summaries/COA_Summary_Already_Exists.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    assert_difference('CoaSummaryFile.count', 1) do
      post :create, coa_summary_file: {:file_url => file, file_kilobytes: @coa_summary_file.file_kilobytes, filename: @coa_summary_file.filename}
      coa_summary_file = CoaSummaryFile.last
      assert_equal coa_summary_file.is_valid, false
      assert_match /TX016151/, coa_summary_file.file_error.error_b
    end
  end


  test "should test that a file_error is created for a coa summary file with duplicate barcodes and barcodes that are not in the bottle fixture" do
    login_chemadmin
    excel_filename = 'files/coa_summaries/COA_Summary_Testing_Job.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    assert_difference('FileError.count', 1, "Coa Summary Validations did not work") do
      post :create, coa_summary_file: {:file_url => file}
    end
    assert_redirected_to coa_summaries_path
    @coa_summary_file = CoaSummaryFile.last
    assert_equal false, @coa_summary_file.is_valid
    assert_match "Tximaduplicatebarcode", @coa_summary_file.file_error.error_a.to_s
    assert_match "VI\nTximaduplicatebarcode\nTximaduplicatebarcode\n", @coa_summary_file.file_error.error_c.to_s
  end

end
