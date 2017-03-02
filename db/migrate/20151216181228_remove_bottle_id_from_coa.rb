class RemoveBottleIdFromCoa < ActiveRecord::Migration
  def change
    remove_reference :coas, :bottle, index: true, foreign_key: true
  end
end
