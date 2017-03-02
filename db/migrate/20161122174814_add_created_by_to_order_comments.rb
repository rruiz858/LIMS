class AddCreatedByToOrderComments < ActiveRecord::Migration
  def change
    add_column :order_comments, :created_by, :string
  end
end
