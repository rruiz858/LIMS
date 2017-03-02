class Vendor < ActiveRecord::Base
  has_many :shipment_files, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :agreements, dependent: :destroy
  has_many :contacts, dependent: :destroy
  has_many :addresses, :through => :contacts
  has_many :agreement_documents, through: :agreements
  has_many :task_orders, through: :agreements
  validates :name, :label,  presence: true
  validates_length_of :name, :minimum => 2
  validates :name, :uniqueness => {:case_sensitive => false}
  validates :label, :uniqueness => {:case_sensitive => false}
  validate :check_format_of_name


  def check_format_of_name
    if errors.blank?
      if self.name.match(/\s+/)
        errors.add(:name, "No empty spaces allowed in short name")
      elsif self.name.include? '_'
        errors.add(:name, "No underscores are allowed in short name")
      end
    end
  end

  def partner_type
   self.mta_partner? ? "MTA Partner" : "Contracted Vendor"
  end

end
