class ChangeExpirationDateToStringInContracts < ActiveRecord::Migration
  def change
    change_column :contracts, :expiration_date, :string
  end
end
