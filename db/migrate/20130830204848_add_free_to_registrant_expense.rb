class AddFreeToRegistrantExpense < ActiveRecord::Migration
  class Registrant < ActiveRecord::Base
  end
  class RegistrantExpenseItem < ActiveRecord::Base
  end

  def up
    add_column :registrant_expense_items, :free, :boolean, default: false
    Registrant.reset_column_information
    RegistrantExpenseItem.reset_column_information

    Registrant.all.each do |reg|
      free_item_id = reg.free_expense_item_id
      unless free_item_id.nil?
        re = RegistrantExpenseItem.new
        re.registrant_id = reg.id
        re.expense_item_id = free_item_id
        re.free = true
        re.save
      end
    end

    remove_column :registrants, :free_expense_item_id
  end

  def down
    add_column :registrants, :free_expense_item_id, :integer
    Registrant.reset_column_information
    RegistrantExpenseItem.reset_column_information

    RegistrantExpenseItem.all.each do |reg_exp|
      if reg_exp.free
        registrant = Registrant.find(reg_exp.registrant_id)
        registrant.free_expense_item_id = reg_exp.expense_item_id
        registrant.save
      end
    end

    remove_column :registrant_expense_items, :free
  end
end
