module OpenExcel
  extend ActiveSupport::Concern
  private

  def open_spreadsheet(file)
    case File.extname(file)
      when ".csv" then
        Roo::CSV.new(file, packed: nil, file_warning: :ignore)
      when ".xls" then
        Roo::Excel.new(file, packed: nil, file_warning: :ignore)
      when ".xlsx" then
        Roo::Excelx.new(file, packed: nil, file_warning: :ignore)
      else
        errors.add(:base, "Unknown file type")
    end
  end

  def additional_headers(file)
    sheet = open_spreadsheet(file)
    results = Comit.new.comit_headers(sheet)
    expected_headers =  results[:expected_headers] += ["cid", "po_number", "freeze_thaw_count", "smiles" ]  #these headers are not part of validation
    additional_headers = results[:headers] - expected_headers
    unless additional_headers.blank?
      notice_string = "The following headers were found in COMIT with no actions taken:" + "\n"
      additional_headers.each{|header| notice_string += header + "\n"}
      flash[:notice] = "#{notice_string}"
    end
  end


  def mutiple_sheets(file)
    excel = open_spreadsheet(file)
    if excel.sheets.count > 1
      flash[:notice] = "File contained mutitple sheets: only first sheet was processed"
    end
  end
end