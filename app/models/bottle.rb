class Bottle < ActiveRecord::Base
  extend ApplicationHelper
  include OpenExcel
  has_many :plate_details, dependent: :destroy
  has_many :vial_details, dependent: :destroy
  belongs_to :coa_summary
  delegate :generic_substance, :to => :coa_summary, :allow_nil => true
  validate :validate_stripped_barcode, on: :create
  has_many :shipments_bottles, dependent: :destroy
  validates :cas, :compound_name, :lot_number, :cid, :cpd, :qty_available_mg_ul, presence: true, if: :external_bottle?
  validates :stripped_barcode, :barcode, uniqueness: true, on: :create
  scope :external, -> { where('external_bottle = 1') }

  def validate_stripped_barcode
    if Bottle.where(stripped_barcode: "#{self.stripped_barcode}").exists?
      errors.add(:Barcode, " '#{self.barcode }' is not unique after stripping to '#{self.stripped_barcode}'")
    end
  end

  def validate_duplicate_barcodes(comit)
    #This checks for duplicate barcodes in the excel file
    #Also it checks for if a bottle is new, but then already is in Bottle table
    bottle_inventory = Bottle.find_by_sql("SELECT barcode, stripped_barcode, qty_available_mg, qty_available_ul FROM bottles;")
    barcode_inventory_array = Array.new
    stripped_inventory_array = Array.new
    barcode_array = Array.new
    for bottle in bottle_inventory.each
      barcode_inventory_array.push(bottle.barcode)
      stripped_inventory_array.push(bottle.stripped_barcode)
    end
    spreadsheet = open_spreadsheet(comit.file_url.path)
    header = spreadsheet.row(1).map(&:downcase)
    (2..spreadsheet.last_row).each do |j|
      row = Hash[[header, spreadsheet.row(j)].transpose]
      @comit_attributes = {:barcode_parent => row['barcode_parent'],
                           :barcode => row['barcode'],
                           :status => row['status'],
                           :compound_name => row['compound_name'],
                           :cas => row['cas'],
                           :cid => row['cid'],
                           :vendor => row['vendor'],
                           :vendor_part_number => row['vendor_part_number'],
                           :qty_available_mg => row['qty_available_mg'],
                           :qty_available_ul => row['qty_available_ul'],
                           :concentration_mm => row['concentration_mm'],
                           :qty_available_umols => row['qty_available_umols'],
                           :structure_real_amw => row['structure_real_amw'],
                           :sam => row['sam'],
                           :cpd => row['cpd'],
                           :po_number => row['po_number'],
                           :lot_number => row['lot_number'],
                           :form => row['form'],
                           :date_record_added => row['date_record_added'],
                           :solubility => row['solubility'],
                           :solubility_details => row['solubility_details'],
                           :solubility_solvent => row['solubility_solvent'],
                           :stripped_barcode => (row['barcode'].to_s).gsub(/^.../, "")}
      barcode_array.push(@comit_attributes)
    end
    array_stripped = []
    bottle_barcodes = []
    stripped_new = []
    for i in 1...barcode_array.length
      array_stripped << (barcode_array[i][:stripped_barcode].to_s)
      bottle_barcodes << (barcode_array[i][:barcode].to_s)
    end
    error_a = ""
    error_b = ""
    duplicate_barcodes = array_stripped.select { |e| array_stripped.count(e) >1 }.uniq
    new_bottles = bottle_barcodes - barcode_inventory_array
    for new_bottle in new_bottles.each
      stripped_new.push(new_bottle.gsub(/^.../, ""))
    end
    new_duplicates = stripped_inventory_array & stripped_new
    total_count = (duplicate_barcodes.count + new_duplicates.count)
    for barcode in duplicate_barcodes.each
      error_a += barcode + "\n"
    end
    for barcode in new_duplicates.each
      error_b += barcode + "\n"
    end
    if !(error_a.blank?) || !(error_b.blank?)
      {:valid => false, :error_a => error_a, :error_b => error_b, :error_count => total_count}
    else
      {:valid => true, :barcode_inventory => bottle_inventory, :comit_bottles => barcode_array}
    end
  end

end

