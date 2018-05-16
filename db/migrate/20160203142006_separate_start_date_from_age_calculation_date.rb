class SeparateStartDateFromAgeCalculationDate < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :age_calculation_base_date, :date
  end
end
