class AddPolymorphicAssociationToDelayedJob < ActiveRecord::Migration
  def up
    change_table :delayed_jobs do |t|
      t.references :job, :polymorphic => true

    end
  end

  def down
    change_table :delayed_jobs do |t|
      t.remove_references :job, :polymorphic => true
    end
  end
end