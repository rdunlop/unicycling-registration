class AddBoundaryCalculationToJudgeType < ActiveRecord::Migration[4.2]
  def change
    add_column :judge_types, :boundary_calculation_enabled, :boolean
  end
end
