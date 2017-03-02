class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :trackable, polymorphic: true

  def self.document_activities(agreement)
    Activity.find_by_sql("SELECT * FROM activities AS a WHERE a.trackable_id IN (SELECT ad.id FROM agreement_documents AS ad WHERE (ad.agreement_id = #{agreement.id} AND a.trackable_type = 'AgreementDocument'));")
  end
end
