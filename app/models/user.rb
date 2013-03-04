class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  default_scope order('email ASC')

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :club

  validates :admin, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :super_admin, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :club_admin, :inclusion => { :in => [true, false] } # because it's a boolean

  has_paper_trail :meta => {:user_id => :id }

  has_many :registrants, :order => "registrants.id", :include => [:registrant_expense_items, :payment_details]

  has_many :payments

  after_initialize :init

  def init
    self.admin = false if self.admin.nil?
    self.super_admin = false if self.super_admin.nil?
    self.club_admin = false if self.club_admin.nil?
  end

  def to_s
    email
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
