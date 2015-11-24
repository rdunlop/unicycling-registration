class RemoveStreetScoreTable < ActiveRecord::Migration
  class StreetScore < ActiveRecord::Base
  end

  def up
    StreetScore.all.each do |street|
      Score.create!(judge_id: street.judge_id, competitor_id: street.competitor_id,
                    val_1: street.val_1)
    end
    drop_table :street_scores
  end

  def down
    create_table :street_scores do |t|
      t.integer  "competitor_id"
      t.integer  "judge_id"
      t.decimal  "val_1", precision: 5, scale: 3
      t.timestamps
    end

    StreetScore.reset_column_information

    jt = JudgeType.find_by(event_class: "Street")
    jt.scores.each do |street|
      StreetScore.create!(judge_id: street.judge_id, competitor_id: street.competitor_id,
                          val_1: street.val_1)
    end
  end
end
