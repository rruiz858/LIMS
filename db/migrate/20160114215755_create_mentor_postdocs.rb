class CreateMentorPostdocs < ActiveRecord::Migration
  def change
    create_table :mentor_postdocs do |t|
      t.integer :cor_id
      t.integer :pd_id
      t.timestamps null: false
    end
  end
end
