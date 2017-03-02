class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :vendor
  belongs_to :task_order
  belongs_to :address
  belongs_to :order_status
  belongs_to :order_concentration
  has_one :order_chemical_list, dependent: :destroy
  has_many :controls, dependent: :destroy
  has_one :order_plate_detail, inverse_of: :order, dependent: :destroy
  has_many :shipment_files, dependent: :destroy
  has_many :plate_details, through: :shipment_files
  has_many :order_comments, as: :commentable, :dependent => :destroy
  accepts_nested_attributes_for :order_plate_detail
  validates_presence_of :vendor_id, :task_order_id, :address_id, :order_concentration_id, :amount


  def plates_needed
   plate_type = self.order_plate_detail.plate_type_label
   count = available_chemicals.count + not_available_chemicals.count
   OrderPlateDetail.plate_count(plate_type, count)
  end

  def procurements
   not_available_chemicals.count
  end

  def dilutions
    0
  end

  def solubilization
    0
  end

  def available_chemicals
   SourceSubstance.available(self.order_chemical_list.chemical_list.id, self.amount, self.order_concentration.concentration)
  end

  def not_available_chemicals
   SourceSubstance.not_available(self.order_chemical_list.chemical_list.id, self.amount, self.order_concentration.concentration)
  end

end
