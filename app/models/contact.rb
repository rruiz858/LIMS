class Contact < ActiveRecord::Base
  belongs_to :vendor
  belongs_to :contact_type
  has_one :address, dependent: :destroy
  accepts_nested_attributes_for :address, :allow_destroy => true
  validates :first_name, :last_name,
            :phone1, :email, :contact_type, presence: true
end
