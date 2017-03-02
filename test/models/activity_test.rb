require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  setup do
    extend ActionDispatch::TestProcess
    @agreement = agreements(:one)
  end

  test "the document activities class method" do
    pdf_filename = '/files/TX015880_COA.pdf'
    file = fixture_file_upload(pdf_filename, 'application/pdf')
    @agreement.agreement_documents.build(file_url: file, agreement_id: @agreement.id).save
    @agreement_document = AgreementDocument.last
    Activity.create(action: "create", trackable: @agreement_document)
    method = Activity.document_activities(@agreement)
    assert_not_nil method
    assert_equal 1, method.count
    assert_equal "AgreementDocument", method.first.trackable_type
  end
end
