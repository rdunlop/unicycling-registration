class AddBoundaryCalculationToJudgeType < ActiveRecord::Migration
  def change
    add_column :judge_types, :boundary_calculation_enabled, :boolean
  end
end
