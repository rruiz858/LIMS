class DelayedJob < ActiveRecord::Base
  belongs_to :job, :polymorphic => true
end