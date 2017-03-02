class AddBlindedSampleIdToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :blinded_sample_id, :string
  end
end
