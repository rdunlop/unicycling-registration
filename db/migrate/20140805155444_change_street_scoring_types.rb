class ChangeStreetScoringTypes < ActiveRecord::Migration
  def up
    jt = JudgeType.find_by(name: "Street Judge Type")
    if jt && jt.val_1_description == "?"
      jt.update_attributes(
        name: "Street Judge Zone 1",
        val_1_description: "Score",
        val_2_description: "n/a",
        val_3_description: "n/a",
        val_4_description: "n/a",
        val_1_max: 100,
        val_2_max: 0,
        val_3_max: 0,
        val_4_max: 0
        )
      jt.save!

      JudgeType.create(name: "Street Judge Zone 2",
                       val_1_description: "Score",
                       val_2_description: "n/a",
                       val_3_description: "n/a",
                       val_4_description: "n/a",
                       val_1_max: 100,
                       val_2_max: 0,
                       val_3_max: 0,
                       val_4_max: 0,
                       event_class: "Street"
        )
      JudgeType.create(name: "Street Judge Zone 3",
                       val_1_description: "Score",
                       val_2_description: "n/a",
                       val_3_description: "n/a",
                       val_4_description: "n/a",
                       val_1_max: 100,
                       val_2_max: 0,
                       val_3_max: 0,
                       val_4_max: 0,
                       event_class: "Street"
        )
    end
  end

  def down
    raise IrreversibleException
  end
end
