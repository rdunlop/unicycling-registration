class RemovePrimaryChoiceAndCategoryChoice < ActiveRecord::Migration
  class EventChoice < ActiveRecord::Base
  end
  class RegistrantChoice < ActiveRecord::Base
  end

  def up
    EventChoice.reset_column_information
    RegistrantChoice.reset_column_information

    EventChoice.where("position = 1 or cell_type = 'category'").each do |ec|
      RegistrantChoice.where(event_choice_id: ec.id).delete_all
      ec.destroy
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
