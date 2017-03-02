class ShipmentFile < ActiveRecord::Base
  extend ApplicationHelper
  include OpenExcel
  belongs_to :user
  belongs_to :vendor
  belongs_to :task_order
  belongs_to :address
  belongs_to :order_concentration
  belongs_to :order
  has_many :plate_details, dependent: :destroy
  has_many :vial_details, dependent: :destroy
  has_many :shipments_bottles, dependent: :destroy
  accepts_nested_attributes_for :shipments_bottles
  has_many :plates, :foreign_key => 'ship_id', :primary_key => 'ship_id', dependent: :destroy
  mount_uploader :file_url, ShipmentUploader
  delegate :agreements, :to => :vendor, :allow_nil => true
  validates :file_url, presence: {message: "Must select a file"}, on: :create
  validates_format_of :original_filename, :with => /\AEPA+_+[\d]+_+[\d]+.+(xls|xlsx|csv)/i, message: "Shipment File should be formated in the following format: EPA_#####_#####.csv|xls|xlsx ", on: :create
  validate :validate_file_name, on: :create
  validates :vendor, presence: {message: "Must select a vendor"}
  validate :validate_order_number_id,:validate_headers
  scope :external, -> { where('external = 1') }
  scope :raw_shipments, -> { where('external = 0') }
  scope :in_progress, -> { where("status = 'In Progress'") }

  def self.move(send_to, shipment_file)
    @shipment_file = ShipmentFile.find_by_filename(shipment_file)
    @location_a = @shipment_file.vendor.name
    @user = @shipment_file.user
    @order_number = @shipment_file.order_number
    @shipment_file.update_attributes(:vendor_id => send_to)
    track_shipment_activity(@shipment_file, @location_a, @user, @order_number)
  end

  def is_mixture?
    self.mixture ? true : false
  end

  def spreadsheet
    open_spreadsheet(self.file_url.path)
  end

  def headers(sheet)
    sheet.row(1).compact.map(&:downcase)
  end

  private

  def validate_file_name
   if self.original_filename =~ /\AEPA+_+[\d]+_+[\d]+.+(xls|xlsx|csv)/i
    evotech_order_num = (self.original_filename)[/\_.*?\_/].gsub(/[_]/, "")
    evotech_shipment_num = (self.original_filename)[/.*\_(.*)...\w/, 1]
    uniqueness_of_evotech_ids('evotech_order_num',evotech_order_num)
    uniqueness_of_evotech_ids('evotech_shipment_num', evotech_shipment_num)
   else
     errors.add(:base, 'Shipment File should be formated in the following format: EPA_#####_#####.csv|xls|xlsx')
   end
  end

  def uniqueness_of_evotech_ids(attribute, value)
    if errors.blank?
      query = ShipmentFile.find_by attribute.to_sym => value
      if query.blank?
        self.send "#{attribute}=", value
      else
        errors.add(:base, "#{attribute} (from EPA filename) must be unique")
      end
    end
  end

  def validate_order_number_id
    if (self.order_number.blank? && self.order.blank?) || (!self.order_number.blank? && !self.order.blank?)
      errors.add(:base, ' Must select an order id or enter an EPA internal order number')
    end
  end

  def validate_extension
    accepted_formats = %w(.xls .xlsx .csv)
    if !accepted_formats.include? File.extname(file_url.path)
      errors.add(:base, 'Wrong extension')
      false
    else
      true
    end
  end

  def validate_mime_type
    mime_types = %w(text/csv application/csv text/comma-separated-values
                      application/excel application/vnd.ms-excel application/msexcel
                      application/x-msexcel application/x-ms-excel application/x-excel
                      application/x-dos_ms_excel application/xls application/x-xls
                      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet)
    unless mime_types.include? file_url.content_type
      errors.add(:base, ' Invalid MIME type')
    end
  end

  def validate_headers
    if self.errors.blank?
    @sheet = spreadsheet
    @headers = headers(@sheet)
    num_of_columns = @sheet.last_column
    error_count = 0
    if num_of_columns < 19
      errors.add(:base, ' * Not enough columns in Shipment File')
      error_count + 1
    end
    headers_array= %w[ism sample_id
                  structure_id structure_real_amw
                  sample_supplier supplier_structure_id
                  aliquot_plate_barcode aliquot_well_id
                  aliquot_solvent aliquot_conc
                  aliquot_conc_unit aliquot_volume
                  aliquot_volume_unit sample_appearance
                  structure_name cas_regno
                  supplier_sample_id aliquot_date
                  solubilized_barcode lts_barcode
                  source_barcode]

    if is_vial?(@headers)
      headers_array -= %w[aliquot_solvent aliquot_conc aliquot_conc_unit aliquot_volume aliquot_volume_unit aliquot_well_id]
      headers_array += %w[aliquot_vial_barcode aliquot_amount aliquot_amount_unit purity purity_method]
    end
    headers_array.each do |i|
      unless @headers.include?(i)
        errors.add(:base, " * #{i} header is missing")
        error_count += 1
      end
    end
   end
  end

  def is_vial?(headers)
    if headers.include?("aliquot_vial_barcode") || headers.include?("aliquot_amount") || headers.include?("aliquot_amount_unit")
      self.vial = true
    else
      false
    end
  end

end