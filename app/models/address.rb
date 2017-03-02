class Address < ActiveRecord::Base
  attr_accessor :override_city
  has_many :orders, dependent: :destroy
  has_many :shipment_files, dependent: :destroy
  belongs_to :contact
  validates :address1, :country, :zip, presence: true
  validates :city, presence: true, unless: :turn_off_city
  validates :address1, :country, :zip, presence: true
  validates :state, presence:  true, if: :united_states?



  def address_country
    "#{self.address1}, #{self.country}"
  end

private
  def turn_off_city
    self.override_city=='false' ? false : true
  end

  def united_states?  #method that returns true if the country selected is the US
    self.country == 'United States' ? true : false
  end

end
