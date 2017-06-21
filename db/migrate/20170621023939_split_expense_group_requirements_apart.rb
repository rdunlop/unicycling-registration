class SplitExpenseGroupRequirementsApart < ActiveRecord::Migration[5.0]
  class ExpenseGroup < ActiveRecord::Base
  end

  class ExpenseGroupFreeOption < ActiveRecord::Base
  end

  def up
    create_table :expense_group_free_options do |t|
      t.integer :expense_group_id, null: false, index: true
      t.string :registrant_type, null: false
      t.string :free_option, null: false
      t.integer :min_age
      t.integer :max_age
      t.timestamps
    end
    add_index :expense_group_free_options, %i[expense_group_id registrant_type], unique: true, name: "free_options_group_reg_type"

    ExpenseGroupFreeOption.reset_column_information

    ExpenseGroup.all.each do |expense_group|
      option = expense_group.competitor_free_options
      if option.present? && option != "None Free"
        ExpenseGroupFreeOption.create!(
          expense_group_id: expense_group.id,
          registrant_type: "competitor",
          free_option: option
        )
      end

      option = expense_group.noncompetitor_free_options
      next unless option.present? && option != "None Free"
      ExpenseGroupFreeOption.create!(
        expense_group_id: expense_group.id,
        registrant_type: "noncompetitor",
        free_option: option
      )
    end
  end

  def down
    drop_table :expense_group_free_options
  end
end
