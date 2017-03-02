class ShipmentsActivity < ActiveRecord::Base
  belongs_to :user
  belongs_to :trackable, polymorphic: true
end
