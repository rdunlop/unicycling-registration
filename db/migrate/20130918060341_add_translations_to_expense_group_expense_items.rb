class AddTranslationsToExpenseGroupExpenseItems < ActiveRecord::Migration
  class ExpenseGroup < ActiveRecord::Base
    translates :group_name
  end
  class ExpenseItem < ActiveRecord::Base
    translates :name, :description, :details_label
  end

  def up
    ExpenseGroup.create_translation_table!({
                                             :group_name => :string
                                           }, {
                                             :migrate_data => true
                                           })
    ExpenseItem.create_translation_table!({
                                            :name => :string,
                                            :description => :string,
                                            :details_label => :string
                                          }, {
                                            :migrate_data => true
                                          })
  end

  def down
    ExpenseGroup.drop_translation_table!({
                                           :migrate_data => true
                                         })
    ExpenseItem.drop_translation_table!({
                                          :migrate_data => true
                                        })
  end
end
