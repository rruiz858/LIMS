class OrderComment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  has_many :order_comments, as: :commentable
  validates :body, presence: true
end
