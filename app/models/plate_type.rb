class PlateType < ActiveRecord::Base
  has_many :order_plate_details, dependent: :destroy
end