class CreateRequiredExpenseItems < ActiveRecord::Migration
  class RegistrantExpenseItem < ActiveRecord::Base
  end

  class Payment < ActiveRecord::Base
  end
  class PaymentDetail < ActiveRecord::Base
    belongs_to :payment
  end

  class Registrant < ActiveRecord::Base
    has_many :payment_details, :include => :payment
  end

  class ExpenseItem < ActiveRecord::Base
  end
  class ExpenseGroup < ActiveRecord::Base
    has_many :expense_items
  end

  def up
    add_column :registrant_expense_items, :system_managed, :boolean, :default => false

    Registrant.reset_column_information
    RegistrantExpenseItem.reset_column_information

    # Create a registrant_expense_item for any registrant who hasn't paid for the required item(s)
    ExpenseGroup.all.each do |eg|
      next unless eg.expense_items.count == 1
      ei = eg.expense_items.first
      Registrant.all.each do |reg|
        next unless (reg.competitor and eg.competitor_required) or ((!reg.competitor) and eg.noncompetitor_required)
        next if reg.payment_details.where(:payments => {:completed  => true}).map { |pd| pd.expense_item_id}.include?(ei.id)
        re = RegistrantExpenseItem.new
        re.registrant_id = reg.id
        re.expense_item_id = ei.id
        re.free = false
        re.system_managed = true
        re.save
      end
    end
  end

  def down
    RegistrantExpenseItem.all.each do |rei|
      next unless rei.system_managed
      rei.delete
    end
    remove_column :registrant_expense_items, :system_managed
  end
end
