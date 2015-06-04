class AddPrecisionAndScaleToPointsOfStandardSkillEntry < ActiveRecord::Migration
  def change
    change_column :standard_skill_entries, :points, :decimal, precision: 6, scale: 2
  end
end
