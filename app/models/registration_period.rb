class RegistrationPeriod < ActiveRecord::Base
  attr_accessible :competitor_expense_item_id, :end_date, :name, :noncompetitor_expense_item_id, :start_date

  validates :start_date, :presence => true
  validates :end_date, :presence => true
  validates :competitor_expense_item, :presence => true
  validates :noncompetitor_expense_item, :presence => true

  belongs_to :competitor_expense_item, :class_name => "ExpenseItem"
  belongs_to :noncompetitor_expense_item, :class_name => "ExpenseItem"


  def self.relevant_period(date)
    RegistrationPeriod.all.each do |rp|
      if rp.start_date < date and date < rp.end_date
        return rp
      end
    end
    return nil
  end
end
