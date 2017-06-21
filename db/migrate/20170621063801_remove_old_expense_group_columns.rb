class RemoveOldExpenseGroupColumns < ActiveRecord::Migration[5.0]
  class ExpenseGroup < ActiveRecord::Base
  end
  class ExpenseGroupFreeOption < ActiveRecord::Base
    belongs_to :expense_group
  end

  def up
    remove_column :expense_groups, :competitor_free_options
    remove_column :expense_groups, :noncompetitor_free_options
  end

  def down
    add_column :expense_groups, :competitor_free_options, :string
    add_column :expense_groups, :noncompetitor_free_options, :string

    ExpenseGroupFreeOption.all.each do |free_option|
      if free_option.registrant_type == "competitor"
        free_option.expense_group.update_column(:competitor_free_options, free_option.free_option)
      end
      if free_option.registrant_type == "noncompetitor"
        free_option.expense_group.update_column(:noncompetitor_free_options, free_option.free_option)
      end
    end
  end
end
