class ChangeRegFeeToRealObject < ActiveRecord::Migration
  class PaymentDetail < ActiveRecord::Base
    belongs_to :payment, inverse_of: :payment_details
    belongs_to :expense_item
    has_one :refund_detail

    scope :completed, -> { includes(:payment).includes(:refund_detail).where(payments: {completed: true}).where({refund_details: {payment_detail_id: nil}}) }
  end

  class Payment < ActiveRecord::Base
    has_many :payment_details, inverse_of: :payment, dependent: :destroy
  end

  class Registrant < ActiveRecord::Base
    has_many :registrant_expense_items, -> { includes :expense_item}, dependent: :destroy
    has_many :payment_details, -> {includes :payment}, dependent: :destroy

    def reg_paid?
      if RegistrationPeriod.paid_for_period(competitor, paid_expense_items).nil?
        false
      else
        true
      end
    end

    def paid_expense_items
      paid_details.map{|pd| pd.expense_item }
    end

    def paid_details
      payment_details.completed.clone
    end
  end

  class RegistrantExpenseItem < ActiveRecord::Base
    belongs_to :registrant
    belongs_to :expense_item, inverse_of: :registrant_expense_items
  end

  class ExpenseItem < ActiveRecord::Base
  end

  class RegistrationPeriod < ActiveRecord::Base
    belongs_to :competitor_expense_item, class_name: "ExpenseItem"
    belongs_to :noncompetitor_expense_item, class_name: "ExpenseItem"

    def last_day
      end_date + 1.day
    end

    def current_period?(date = Date.today)
      (start_date <= date && date <= last_day)
    end

    def self.all_registration_expense_items
      RegistrationPeriod.all.collect{|rp| rp.competitor_expense_item} + RegistrationPeriod.all.collect{|rp| rp.noncompetitor_expense_item}
    end
    def self.relevant_period(date)
      RegistrationPeriod.includes(:competitor_expense_item, :noncompetitor_expense_item).all.each do |rp|
        if rp.current_period?(date)
          return rp
        end
      end
      nil
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

  def up
    PaymentDetail.reset_column_information
    Payment.reset_column_information
    Registrant.reset_column_information
    RegistrantExpenseItem.reset_column_information
    ExpenseItem.reset_column_information
    RegistrationPeriod.reset_column_information

    # determine the current competitor expense item, and non-competitor expense item
    rp = RegistrationPeriod.relevant_period(Date.today)
    unless rp.nil?
      Registrant.all.each do |reg|
        if reg.competitor
          ei = rp.competitor_expense_item
        else
          ei = rp.noncompetitor_expense_item
        end

        # go through every registrant, and create a system entry for that expense item if they haven't paid for registration.
        unless reg.reg_paid?
          rei = reg.registrant_expense_items.build({expense_item_id: ei.id, system_managed: true})
          puts "creating REI of #{ei.id} for reg: #{reg.bib_number}"
          rei.save!
        else
          puts "Skipping creating REI for reg #{reg.bib_number}"
        end
      end
    end
  end

  def down
    # remove any registrant_expense_items from the set of registration_fees
    RegistrationPeriod.all_registration_expense_items.each do |ei|
      RegistrantExpenseItem.where({expense_item_id: ei.id}).each do |rei|
        puts "deleting rei for #{rei.registrant.bib_number}"
        rei.destroy
      end
    end
  end
end
