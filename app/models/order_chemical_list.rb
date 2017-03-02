class OrderChemicalList < ActiveRecord::Base
  belongs_to :order
  belongs_to :chemical_list, foreign_key: 'chemical_list_id'
end
