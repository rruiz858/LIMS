require 'test_helper'

class ComitTest < ActiveSupport::TestCase
  setup do
    extend ActionDispatch::TestProcess
  end

  test 'the truth' do
    assert true
  end

  test "should not save without a file_url " do
    comit = Comit.new
    comit.file_url = nil
    assert !comit.save, "Saved the Comit without a file_url"
    assert_match /Must select a file/, comit.errors[:file_url].to_s
  end

  test "should save a file that contains no errors" do
    excel_filename = '/files/1439912095_short_EPA_report.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    comit = Comit.new(:file_url => file)
    assert_empty comit.errors.messages, "saved the file with errors"
    assert comit.save, "Did not save"
  end

  test "should upload a Comit without the CID field " do
    excel_filename = '/files/NO_CID_COMIT_TEST.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    comit = Comit.new(:file_url => file)
    assert comit.save, "Did not save"
  end

  test "should allow the saving of a xlsx file" do
    xlsx = '/files/xlsx_comit.xlsx'
    file = fixture_file_upload(xlsx, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    comit = Comit.new(:file_url => file)
    assert_nil comit.errors.messages[:file_url], "This file has errors when it shouldn't have any"
    assert comit.save
  end

end