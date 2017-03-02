require 'test_helper'

class ProcessComitJobTest < ActiveJob::TestCase
  setup do
    extend ActionDispatch::TestProcess
  end

  test "should record number of updates, deletes, and updates from a COMIT import " do
    excel_filename = '/files/short_EPA_report_test_12_8.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    @comit = Comit.create(file_url: file)
    ProcessComitJob.new @comit
    assert_equal true, @comit.is_valid
    assert_equal 47, @comit.inserts
    assert_equal 2, @comit.deletes
    assert_equal 4, @comit.updates
    assert_equal nil, @comit.bottle_error
  end

  test "should not change the Bottle inventory from an invalid COMIT with errors " do
    excel_filename = '/files/Duplicate_Bardcodes_COMIT.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    @comit = Comit.create(:file_url => file)
    ProcessComitJob.new @comit
    invalid_barcodes = Regexp.union(/TX015882/, /TX015880/)
    assert_equal false, @comit.is_valid
    assert_match invalid_barcodes, @comit.description
    assert_equal nil, @comit.inserts
    assert_equal nil, @comit.deletes
    assert_equal nil, @comit.updates
    assert_equal 2, @comit.bottle_error
  end

  test "should not save a COMIT with duplicate stripped barcodes" do
    excel_filename = '/files/Duplicate_Stripped_Bardcodes_COMIT.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    @comit = Comit.new(:file_url => file)
    ProcessComitJob.new @comit
    invalid_barcodes = Regexp.union(/TX015883/, /TX015881/, /TX015880/)
    assert_equal false, @comit.is_valid
    assert_match invalid_barcodes, @comit.description
    assert_equal nil, @comit.inserts
    assert_equal nil, @comit.deletes
    assert_equal nil, @comit.updates
    assert_equal 3, @comit.bottle_error
  end

end
