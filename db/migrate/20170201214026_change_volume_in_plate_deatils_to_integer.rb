class ChangeVolumeInPlateDeatilsToInteger < ActiveRecord::Migration

  def up
    change_column :plate_details, :aliquot_volume, :integer
  end

  def down
      change_column :plate_details, :aliquot_volume, :string
  end

end
