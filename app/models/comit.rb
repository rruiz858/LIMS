class Comit < ActiveRecord::Base
  include OpenExcel
  mount_uploader :file_url, ComitUploader
  belongs_to :user
  has_one :delayed_job, :as => :job
  has_one :file_error, as: :errorable, dependent: :destroy
  validates :file_url, presence: {message: "Must select a file"}
  validate :validate_excel, :validate_content_type


  def validate_content_type
    # print file_url.content_type
    unless file_url.path.blank?
      mime_types = ["text/csv", "application/csv", "text/comma-separated-values", "application/excel", "application/vnd.ms-excel", "application/msexcel", "application/x-msexcel", "application/x-ms-excel", "application/x-excel", "application/x-dos_ms_excel", "application/xls", "application/x-xls", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"]
      unless mime_types.include? file_url.content_type
        errors.add(:file_url, ' * Invalid .xls MIME type')
      end
    end
  end


  def validate_excel
    if errors.blank?
      accepted_formats = [".xls", ".xlsx", ".csv"]
      if accepted_formats.include? File.extname(file_url.path)
        sheet = open_spreadsheet(file_url.path)
        num_of_columns = sheet.last_column
        if num_of_columns < 21
          errors.add(:file_url, ' * Not enough columns in Shipment File')
        end
       results = comit_headers(sheet)
          results[:expected_headers].each do |i|
            unless results[:headers].include?(i)
              errors.add(:file_url, " * #{i} header is missing")
            end
          end
        self.bottle_count= sheet.count
      end
    else
      errors.add(:file_url, 'Wrong extension')
    end
  end

  def comit_headers(sheet)
    expected_headers= %w[barcode barcode_parent
                  status compound_name cas
                  vendor vendor_part_number qty_available_mg
                  qty_available_ul concentration_mm qty_available_umols
                  structure_real_amw sam cpd lot_number form date_record_added
                  solubility solubility_details solubility_solvent]
    headers = sheet.row(1).map(&:downcase)
    {:expected_headers => expected_headers , :headers => headers}
  end
end



