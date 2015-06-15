class UpdateFlatlandJudgeType < ActiveRecord::Migration
  class JudgeType < ActiveRecord::Base
  end

  def up
    judge_type = JudgeType.find_by(name: "Flatland Judge Type", event_class: "Flatland")

    if judge_type
      judge_type.update_attributes(
        val_1_description: "Variety",
        val_2_description: "Consistency/Flow",
        val_3_description: "Difficulty",
        val_4_description: "Last Trick",
        val_1_max: 30,
        val_2_max: 30,
        val_3_max: 30,
        val_4_max: 9
      )
    end
  end

  def down
  end
end
