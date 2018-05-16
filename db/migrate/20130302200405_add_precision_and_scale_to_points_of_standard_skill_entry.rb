class AddPrecisionAndScaleToPointsOfStandardSkillEntry < ActiveRecord::Migration[4.2]
  def change
    change_column :standard_skill_entries, :points, :decimal, precision: 6, scale: 2
  end
end
