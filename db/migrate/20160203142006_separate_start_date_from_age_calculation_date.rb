class SeparateStartDateFromAgeCalculationDate < ActiveRecord::Migration
  def change
    add_column :event_configurations, :age_calculation_base_date, :date
  end
end
