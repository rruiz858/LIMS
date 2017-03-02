class Agreement < ActiveRecord::Base
  belongs_to :agreement_status
  belongs_to :vendor
  belongs_to :user
  has_many :task_orders, dependent: :destroy
  validates :revoke_reason, presence: true, if: -> (agreement){agreement.agreement_status.status == 'Revoked'}, :on => [:update]
  validates :name, :description, :vendor_id, :user_id, presence: true
  validates :expiration_date, presence: true, if: :active?
  has_many :agreement_documents, :inverse_of => :agreement, dependent: :destroy
  before_create :set_agreement_status
  accepts_nested_attributes_for :agreement_documents, allow_destroy: true, :reject_if => lambda { |a| a['file_url'].blank?}

  def set_agreement_status
    self.agreement_status_id = AgreementStatus.find_by_status("new").id
  end

end
