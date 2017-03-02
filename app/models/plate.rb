class Plate < ActiveRecord::Base
  belongs_to :shipment_file, :foreign_key=> 'ship_id', :primary_key => 'ship_id'
  has_many :plate_details, :foreign_key => 'aliquot_plate_barcode', :primary_key => 'aliquot_plate_barcode', dependent: :destroy
  has_many :vial_details, :foreign_key => 'aliquot_plate_barcode', :primary_key => 'aliquot_plate_barcode', dependent: :destroy
end

