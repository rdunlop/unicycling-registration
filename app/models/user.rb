class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :confirmable unless (!ENV['MAIL_SKIP_CONFIRMATION'].nil? and ENV['MAIL_SKIP_CONFIRMATION'] == "true")

  default_scope order('email ASC')

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  has_paper_trail :meta => {:user_id => :id }

  has_many :registrants, :order => "registrants.id", :include => [:registrant_expense_items, :payment_details]

  has_many :additional_registrant_accesses, :dependent => :destroy
  has_many :invitations, :through => :registrants, :class_name => "AdditionalRegistrantAccess", :source => :additional_registrant_accesses

  has_many :judges

  has_many :payments

  has_many :import_results
  has_many :award_labels

  def self.roles
    # these should be sorted in order of least-priviledge -> Most priviledge
    [:judge, :admin, :super_admin]
  end

  def self.role_description(role)
    case(role)
      #when :track_official
      #when :results_printer
      #when :data_importer
    when :judge
      "[e.g. Judge Volunteers] Able to view the judging menu, and enter scores for any event"
    when :admin
      "[e.g. Scott/Connie] 
      Able to create onsite payments, 
      adjust many details of the system.
      can create/assign judges
      Can assign Chief Judges
      Can import Results
      Can Create Award Labels
      "
    when :super_admin
      "[e.g. Robin] Able to set roles of other people, able to destroy payment information, able to configure the site settings, event settings"
    else
      "No Description Available"
    end
  end
  def to_s
    email
  end

  def accessible_registrants
    additional_registrant_accesses.permitted.map{ |ada| ada.registrant} + registrants
  end

  def total_owing
    total = 0
    self.registrants.each do |reg|
      total += reg.amount_owing
    end
    total
  end

  def has_minor?
    self.registrants.each do |reg|
      if reg.minor?
        return true
      end
    end
    false
  end
end
