class ChangeStandardSkillScoreDefaults < ActiveRecord::Migration
  def up
    change_column_default :standard_skill_score_entries, :difficulty_devaluation_percent, 0
    change_column_default :standard_skill_score_entries, :wave, 0
    change_column_default :standard_skill_score_entries, :line, 0
    change_column_default :standard_skill_score_entries, :cross, 0
    change_column_default :standard_skill_score_entries, :circle, 0
  end

  def down
    change_column_default :standard_skill_score_entries, :difficulty_devaluation_percent, nil
    change_column_default :standard_skill_score_entries, :wave, nil
    change_column_default :standard_skill_score_entries, :line, nil
    change_column_default :standard_skill_score_entries, :cross, nil
    change_column_default :standard_skill_score_entries, :circle, nil
  end
end
