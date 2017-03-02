class CoaUpload < ActiveRecord::Base
  mount_uploaders :coa_pdfs, CoaPdfUploader
end
