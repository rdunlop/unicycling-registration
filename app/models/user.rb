class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body

  validates :admin, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :super_admin, :inclusion => { :in => [true, false] } # because it's a boolean

  has_many :registrants

  after_initialize :init

  def init
    self.admin = false if self.admin.nil?
    self.super_admin = false if self.super_admin.nil?
  end
end
