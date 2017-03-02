class MsdsUpload < ActiveRecord::Base
  mount_uploaders :msds_pdfs, MsdsPdfUploader
end
