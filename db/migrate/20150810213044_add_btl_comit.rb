class AddBtlComit < ActiveRecord::Migration
    def change
      create_table :btl_comits do |t|
        t.belongs_to :comit
        t.belongs_to :bottle

        t.timestamps null: false
      end
    end
end
