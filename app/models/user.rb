class User < ActiveRecord::Base
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
