class RegistrationPeriod < ActiveRecord::Base
  attr_accessible :competitor_expense_item_id, :end_date, :name, :noncompetitor_expense_item_id, :start_date

  default_scope order('start_date ASC')

  validates :start_date, :presence => true
  validates :end_date, :presence => true
  validates :competitor_expense_item, :presence => true
  validates :noncompetitor_expense_item, :presence => true

  belongs_to :competitor_expense_item, :class_name => "ExpenseItem"
  belongs_to :noncompetitor_expense_item, :class_name => "ExpenseItem"


  def current_period?(date = Date.today)
    return (self.start_date < date and date < self.end_date)
  end

  def past_period?(date = Date.today)
    return (self.end_date < date)
  end

  def self.relevant_period(date)
    RegistrationPeriod.all.each do |rp|
      if rp.current_period?(date)
        return rp
      end
    end
    return nil
  end

  def self.paid_for_period(competitor, paid_items)
    RegistrationPeriod.includes(:noncompetitor_expense_item).includes(:competitor_expense_item).each do |rp|
      if competitor
        if paid_items.include?(rp.competitor_expense_item)
          return rp
        end
      else
        if paid_items.include?(rp.noncompetitor_expense_item)
          return rp
        end
      end
    end
    nil
  end
end
