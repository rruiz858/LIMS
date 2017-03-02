class AddComitToDelayedJobs < ActiveRecord::Migration
  def change
    add_reference :delayed_jobs, :comit, index: true, foreign_key: true
  end
end
