class AddCommentToBottles < ActiveRecord::Migration
  def change
    add_column :bottles, :comment, :text
  end
end
