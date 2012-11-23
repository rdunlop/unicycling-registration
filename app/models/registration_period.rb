class RegistrationPeriod < ActiveRecord::Base
  attr_accessible :competitor_cost, :end_date, :name, :noncompetitor_cost, :start_date

  validates :start_date, :presence => true
  validates :end_date, :presence => true
  validates :competitor_cost, :presence => true
  validates :noncompetitor_cost, :presence => true


  def self.relevant_period(date)
    RegistrationPeriod.all.each do |rp|
      if rp.start_date < date and date < rp.end_date
        return rp
      end
    end
    return nil
  end
end
