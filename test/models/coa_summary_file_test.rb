require 'test_helper'

class CoaSummaryFileTest < ActiveSupport::TestCase

  setup do
    extend ActionDispatch::TestProcess
    @user = users(:superadmin)
  end


  test "should not save without a file_url " do
    coa_summary_file = CoaSummaryFile.new
    coa_summary_file.file_url = nil
    assert !coa_summary_file.save, "Saved the COA Summary File without a file_url"
    assert_match /Must select a file/, coa_summary_file.errors[:file_url].to_s
  end

  test "validate coa_summary that has no error" do
    excel_filename = '/files/coa_summaries/Coa_summary_file_test.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    coa_summary_file = CoaSummaryFile.new(:file_url => file, user_id: @user.id)
    assert_nil coa_summary_file.errors.messages[:file_url], "This file has errors when it shouldn't have any"
  end

  test "validate coa_summary that has errors" do
    excel_filename = '/files/EPAReport_20150702129999.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    coa_summary_file = CoaSummaryFile.new(:file_url => file, user_id: @user.id)
    coa_summary_file.save
    assert_not_nil coa_summary_file.errors.messages, "This file does not have errors when it should"
  end

  test "should allow the saving of a xlsx file" do
    xlsx = '/files/coa_summaries/Coa_summary_file_test_xlsx.xlsx'
    file = fixture_file_upload(xlsx, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    coa_summary_file = CoaSummaryFile.new(:file_url => file, user_id: @user.id)
    assert_nil coa_summary_file.errors.messages[:file_url], "This file has errors when it shouldn't have any"
    assert coa_summary_file.save
  end

end
