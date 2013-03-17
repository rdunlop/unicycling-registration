class ChangeAllMultiplesToCategories < ActiveRecord::Migration
  class EventChoice < ActiveRecord::Base
  end

  def up
    EventChoice.reset_column_information
    EventChoice.all.each do |ec|
      if ec.cell_type == 'multiple'
        ec.cell_type = 'category'
        ec.save!
      end
    end
  end

  def down
    EventChoice.reset_column_information
    EventChoice.all.each do |ec|
      if ec.cell_type == 'category'
        ec.cell_type = 'multiple'
        ec.save!
      end
    end
  end
end
