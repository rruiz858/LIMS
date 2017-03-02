class PlateDetail < ActiveRecord::Base
  belongs_to :bottle
  belongs_to :shipment_file
  belongs_to :plate, :foreign_key => 'aliquot_plate_barcode', :primary_key => 'aliquot_plate_barcode'
  belongs_to :sample, :foreign_key => 'source_barcode', :primary_key => 'source_barcode'
  scope :mapped_other, -> { where('mapped_other = true') }
end
