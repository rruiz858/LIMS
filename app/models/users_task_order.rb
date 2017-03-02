class UsersTaskOrder < ActiveRecord::Base
  belongs_to :user
  belongs_to :task_order
end
