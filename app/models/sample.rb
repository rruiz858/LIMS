class Sample < ActiveRecord::Base
  self.primary_key = 'source_barcode'
  has_one :plate_detail, dependent: :destroy, foreign_key: 'source_barcode'
end