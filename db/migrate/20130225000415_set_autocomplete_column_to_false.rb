class SetAutocompleteColumnToFalse < ActiveRecord::Migration
  class EventChoice < ActiveRecord::Base
  end

  def up
    EventChoice.reset_column_information
    EventChoice.all.each do |ec|
      ec.autocomplete = false if ec.autocomplete.nil?
      ec.save!
    end
  end

  def down
  end
end
