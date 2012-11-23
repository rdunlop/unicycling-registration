class Registrant < ActiveRecord::Base
  attr_accessible :address_line_1, :address_line_2, :birthday, :city, :country, :email, :first_name, :gender, :last_name, :middle_initial, :mobile, :phone, :state, :zip_code, :user_id

  validates :birthday, :presence => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :city, :presence => true
  validates :country, :presence => true
  validates :gender, :presence => true
  validates :user_id, :presence => true

  validates :competitor, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :gender, :inclusion => {:in => %w(Male Female), :message => "%{value} must be either 'Male' or 'Female'"}


  belongs_to :user
  has_many :registrant_choices


  def name
    self.first_name + " " + self.last_name
  end

  def amount_owing
    rp = RegistrationPeriod.relevant_period(Date.today)
    if rp.nil?
      0
    else
      if self.competitor
        return rp.competitor_cost
      else
        return rp.noncompetitor_cost
      end
    end
  end

  def to_s
    name
  end
end
