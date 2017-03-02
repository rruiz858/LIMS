require 'test_helper'

class CoaTest < ActiveSupport::TestCase
  setup do
    extend ActionDispatch::TestProcess
  end
  test "the truth" do
    assert true
  end
  test "Should not save a COA file that does not map to a COA Summary" do
    no_coa_summary = '/files/TX0000000_COA.pdf'
    file = fixture_file_upload(no_coa_summary, 'application/excel')
    coa = Coa.create(file_url: [file], filename: "TX0000000_COA.pdf")
    assert !coa.save, "Saved the COA file that did not mapp to a COA Summary record"
  end
end
