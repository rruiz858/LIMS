
class MsdTest < ActiveSupport::TestCase
  require 'test_helper'
  setup do
    extend ActionDispatch::TestProcess
  end
  test "Should not save a MSDS file that does not map to a COA Summary" do
    no_coa_summary = '/files/TX0000000_MSDS.pdf'
    file = fixture_file_upload(no_coa_summary, 'application/excel')
    msds = Coa.create(file_url: [file], filename: "TX0000000_MSDS.pdf")
    assert !msds.save, "Saved the MSDS file that did not mapp to a COA Summary record"
  end
end
