class DeleteMentorPostDocAgain < ActiveRecord::Migration
  def change
      drop_table :mentor_postdocs
  end
end
