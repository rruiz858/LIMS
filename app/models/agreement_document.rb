class AgreementDocument < ActiveRecord::Base
  belongs_to :agreement, :inverse_of => :agreement_documents
  mount_uploader :file_url, AgreementDocumentsUploader
end
