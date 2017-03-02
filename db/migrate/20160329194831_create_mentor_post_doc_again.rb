class CreateMentorPostDocAgain < ActiveRecord::Migration
  def change
    create_table :mentor_postdocs do |t|
      t.references :post_doc
      t.references :cor
      t.timestamps null: false
    end
  end
end
