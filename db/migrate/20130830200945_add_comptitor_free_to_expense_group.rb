class AddComptitorFreeToExpenseGroup < ActiveRecord::Migration
  class EventConfiguration < ActiveRecord::Base
  end
  class ExpenseGroup < ActiveRecord::Base
  end

  def up
    add_column :expense_groups, :competitor_free_options, :string
    add_column :expense_groups, :noncompetitor_free_options, :string

    EventConfiguration.reset_column_information
    ExpenseGroup.reset_column_information

    EventConfiguration.all.each do |ec|
      unless ec.competitor_free_item_expense_group_id.nil?
        eg = ExpenseGroup.find(ec.competitor_free_item_expense_group_id)
        eg.competitor_free_options = "One Free In Group"
        eg.save
      end
      unless ec.noncompetitor_free_item_expense_group_id.nil?
        eg = ExpenseGroup.find(ec.noncompetitor_free_item_expense_group_id)
        eg.noncompetitor_free_options = "One Free In Group"
        eg.save
      end
    end

    remove_column :event_configurations, :competitor_free_item_expense_group_id
    remove_column :event_configurations, :noncompetitor_free_item_expense_group_id
  end

  def down
    add_column :event_configurations, :competitor_free_item_expense_group_id, :integer
    add_column :event_configurations, :noncompetitor_free_item_expense_group_id, :integer

    EventConfiguration.reset_column_information
    ExpenseGroup.reset_column_information

    ec = EventConfiguration.first
    unless ec.nil?
      ExpenseGroup.all.each do |eg|
        if eg.competitor_free_options == "One Free In Group"
          ec.competitor_free_item_expense_group_id = eg.id
          ec.save
        end
        if eg.noncompetitor_free_options == "One Free In Group"
          ec.noncompetitor_free_item_expense_group_id = eg.id
          ec.save
        end
      end
    end

    remove_column :expense_groups, :competitor_free_options
    remove_column :expense_groups, :noncompetitor_free_options
  end
end
