class RegistrationPeriod < ActiveRecord::Base
  attr_accessible :competitor_cost, :end_date, :name, :noncompetitor_cost, :start_date

  validates :start_date, :presence => true
  validates :end_date, :presence => true
  validates :competitor_cost, :presence => true
  validates :noncompetitor_cost, :presence => true

end
