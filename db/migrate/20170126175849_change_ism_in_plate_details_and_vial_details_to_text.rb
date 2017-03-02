class ChangeIsmInPlateDetailsAndVialDetailsToText < ActiveRecord::Migration
  def self.up
    change_table :plate_details do |t|
      t.change :ism, :text
    end
    change_table :vial_details do |t|
      t.change :ism, :text
    end
  end


  def self.down
    change_table :plate_details do |t|
      t.change :ism, :string
    end

    change_table :vial_details do |t|
      t.change :ism, :string
    end

  end
end
