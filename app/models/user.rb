class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  belongs_to :role
  has_many :comits, dependent: :destroy
  has_many :coas, dependent: :destroy
  has_many :msds, dependent: :destroy
  has_many :coa_summary_files, dependent: :destroy
  has_many :activities , dependent: :destroy
  has_many :shipments_activities, dependent: :destroy
  has_many :coa_summaries, dependent: :destroy
  has_many :shipment_files, dependent: :destroy
  has_many :users_task_orders, dependent: :destroy
  has_many :postdocs,
           :class_name => 'MentorPostdoc',
           :foreign_key => 'cor_id', dependent: :destroy
  has_many :cors,
           :class_name => 'MentorPostdoc',
           :foreign_key => 'post_doc_id', dependent: :destroy

  has_many :task_orders, through: :users_task_orders,dependent: :destroy
  has_many :agreements, dependent: :destroy
  has_many :vendors, through: :agreements, dependent: :destroy
  has_many :task_orders, through: :agreements, dependent: :destroy
  has_many :orders, dependent: :destroy
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable
  validates :email, uniqueness: {message: "This email is already taken"}
  validates :role_id, presence: {message: "Must select a role"}
  validates :username, presence: {message: "Must include username"}


  def self.cor(current_user)
    MentorPostdoc.select(:id, :cor_id, :post_doc_id).where(post_doc_id: current_user.id)
  end

  def full_name
    "#{self.f_name} #{self.l_name}"
  end

end
