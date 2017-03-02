class RemoveBottleIdFromMsds < ActiveRecord::Migration
  def change
    remove_reference :msds, :bottle, index: true, foreign_key: true
  end
end
