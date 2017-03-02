class TaskOrder < ActiveRecord::Base
  belongs_to :vendor
  belongs_to :agreement
  delegate :vendor, :to => :agreement, :allow_nil => true
  delegate :user, :to => :agreement, :allow_nil => true
  has_many :orders, :dependent => :destroy
  has_many :users_task_orders, dependent: :destroy
  has_many :users, through: :users_task_orders
  has_many :shipment_files, :dependent => :destroy
  validates :name, :description, :vendor_id, :agreement_id, presence: true
end
