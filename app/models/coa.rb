class Coa < ActiveRecord::Base
  belongs_to :user
  belongs_to :coa_summary
  validates :filename, presence: {message: "Must select a file"}
  validates :coa_summary_id, presence: {message:"COA Summary record does not exist for "}
end