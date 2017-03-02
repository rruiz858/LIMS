class OrderPlateDetail < ActiveRecord::Base
  belongs_to :user
  belongs_to :plate_type
  belongs_to :order, inverse_of: :order_plate_detail
  delegate :label, :to => :plate_type, prefix: true
  delegate :numeric_value, :to => :plate_type, prefix: true

  def self.plate_count(plate_type, chemical_count)
    if plate_type == "vials"
      return "#{chemical_count} vials"
    elsif plate_type == "96 plate"
      plate_integer = 96
      OrderPlateDetail.division(plate_integer, chemical_count)
    elsif plate_type == "384 plate"
      plate_integer = 384
      OrderPlateDetail.division(plate_integer, chemical_count)
    end
  end

  def self.division(plate_integer, chemical_count)
    float = chemical_count.to_f / plate_integer.to_f
    count = float.ceil
    return count
  end

end
