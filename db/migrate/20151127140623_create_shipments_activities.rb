class CreateShipmentsActivities < ActiveRecord::Migration
  def change
    create_table :shipments_activities do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :action
      t.string :location_a
      t.string :location_b
      t.belongs_to :trackable, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
