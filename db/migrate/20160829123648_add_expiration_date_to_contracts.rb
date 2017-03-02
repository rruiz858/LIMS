class AddExpirationDateToContracts < ActiveRecord::Migration
  def change
    add_column :contracts, :expiration_date, :date
  end
end
