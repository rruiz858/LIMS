require 'test_helper'

class BottleTest < ActiveSupport::TestCase
  setup do
    extend ActionDispatch::TestProcess
    @bottle = bottles(:one)
  end
  test "the truth" do
    assert true
  end

  test "the validate_duplicate_barcodes class method when successful comit upload" do
    excel_filename = '/files/short_EPA_report_test_12_8.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    @comit = Comit.create(file_url: file)
    validation = Bottle.new.validate_duplicate_barcodes(@comit)
    assert_equal true, validation[:valid]
  end

  test "the validate_duplicate_barcodes class method when unsuccessful comit upload" do
    excel_filename = '/files/Duplicate_Stripped_Bardcodes_COMIT.xls'
    file = fixture_file_upload(excel_filename, 'application/excel')
    @comit = Comit.create(:file_url => file)
    validation = Bottle.new.validate_duplicate_barcodes(@comit)
    invalid_barcodes = Regexp.union(/TX015881/, /TX015883/)
    assert_equal false, validation[:valid]
    assert_match invalid_barcodes, validation[:error_a]
    assert_equal 2, validation[:error_count]
  end

  test "bottle should not be saved if the stripped_barcode is not unique" do
    bottle = Bottle.create(stripped_barcode: @bottle.stripped_barcode,
                           cas: @bottle.cas,
                           compound_name: @bottle.compound_name,
                           qty_available_mg: @bottle.qty_available_mg,
                           lot_number: @bottle.lot_number,
                           cid: @bottle.cid, cpd: @bottle.cpd)
   assert_match  /Stripped barcode has already been taken/, bottle.errors.full_messages.to_s
  end

  test "invalid external bottle should not be save without a cas, name, lot number,cpd" do
    bottle = Bottle.create(stripped_barcode: "TX78323902",
                           external_bottle: 1,
                           cas: "",
                           compound_name: "",
                           qty_available_mg: @bottle.qty_available_mg,
                           lot_number: @bottle.lot_number,
                           cid: @bottle.cid, cpd: "")
    assert_match /Cas can't be blank/, bottle.errors.full_messages.to_s
    assert_match /Compound name can't be blank/, bottle.errors.full_messages.to_s
    assert_match /Cpd can't be blank/, bottle.errors.full_messages.to_s
  end



end
