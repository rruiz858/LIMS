class OrderConcentration < ActiveRecord::Base
  has_many :orders, dependent: :destroy
  has_many :shipment_files, dependent: :destroy
end