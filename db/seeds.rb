# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

JudgeType.find_or_create_by(name: "Presentation", event_class: "Freestyle") do |judge_type|
  judge_type.assign_attributes(
    val_1_description: "Mistakes: Dismounts",
    val_2_description: "Choreography & Style",
    val_3_description: "Showmanship and Originality",
    val_4_description: "Interpretation",
    val_1_max: 10,
    val_2_max: 15,
    val_3_max: 15,
    val_4_max: 10
  )
end
JudgeType.find_or_create_by(name: "Technical", event_class: "Freestyle") do |judge_type|
  judge_type.assign_attributes(
    val_1_description: "Quantity of Unicycling Skills & Transitions",
    val_2_description: "Mastery and Quality of Execution",
    val_3_description: "Difficulty and Duration",
    val_4_description: "N/A",
    val_1_max: 10,
    val_2_max: 15,
    val_3_max: 15,
    val_4_max: 0
  )
end

JudgeType.find_or_create_by(name: "Flatland Judge Type", event_class: "Flatland") do |judge_type|
  judge_type.assign_attributes(
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

JudgeType.find_or_create_by(name: "High/Long Judge Type", event_class: "High/Long") do |judge_type|
  judge_type.assign_attributes(
    val_1_description: "?",
    val_2_description: "?",
    val_3_description: "?",
    val_4_description: "?",
    val_1_max: 10,
    val_2_max: 10,
    val_3_max: 10,
    val_4_max: 10
  )
end

JudgeType.find_or_create_by(name: "Street Judge Zone 1", event_class: "Street") do |judge_type|
  judge_type.assign_attributes(
    val_1_description: "Score",
    val_2_description: "n/a",
    val_3_description: "n/a",
    val_4_description: "n/a",
    val_1_max: 100,
    val_2_max: 0,
    val_3_max: 0,
    val_4_max: 0
  )
end

JudgeType.find_or_create_by(name: "Street Judge Zone 2", event_class: "Street") do |judge_type|
  judge_type.assign_attributes(
    val_1_description: "Score",
    val_2_description: "n/a",
    val_3_description: "n/a",
    val_4_description: "n/a",
    val_1_max: 100,
    val_2_max: 0,
    val_3_max: 0,
    val_4_max: 0
  )
end

JudgeType.find_or_create_by(name: "Street Judge Zone 3", event_class: "Street") do |judge_type|
  judge_type.assign_attributes(
    val_1_description: "Score",
    val_2_description: "n/a",
    val_3_description: "n/a",
    val_4_description: "n/a",
    val_1_max: 100,
    val_2_max: 0,
    val_3_max: 0,
    val_4_max: 0
  )
end

JudgeType.find_or_create_by(name: "Performance", event_class: "Artistic Freestyle IUF 2015") do |judge_type|
  judge_type.assign_attributes(
    val_1_description: "Mistakes: Dismounts",
    val_2_description: "Presence/Execution",
    val_3_description: "Composition/Choreography",
    val_4_description: "Interpretation of the Music/Timing",
    val_1_max: 10,
    val_2_max: 10,
    val_3_max: 10,
    val_4_max: 10
  )
end

JudgeType.find_or_create_by(name: "Technical", event_class: "Artistic Freestyle IUF 2015") do |judge_type|
  judge_type.assign_attributes(
    val_1_description: "Quantity of Unicycling Skills & Transitions",
    val_2_description: "Mastery and Quality of Execution",
    val_3_description: "Difficulty and Duration",
    val_4_description: "N/A",
    val_1_max: 10,
    val_2_max: 15,
    val_3_max: 15,
    val_4_max: 0
  )
end

JudgeType.find_or_create_by(name: "Writing", event_class: "Standard Skill") do |judge_type|
  judge_type.assign_attributes(
    val_1_description: "n/a",
    val_2_description: "n/a",
    val_3_description: "n/a",
    val_4_description: "n/a",
    val_1_max: 0,
    val_2_max: 0,
    val_3_max: 0,
    val_4_max: 0
  )
end

if WheelSize.count == 0
  WheelSize.create(position: 1, description: "16\" Wheel")
  WheelSize.create(position: 2, description: "20\" Wheel")
  WheelSize.create(position: 3, description: "24\" Wheel")
end

if StandardSkillEntry.count == 0
  StandardSkillEntry.create(description: "riding", number: 1, letter: 'a', points: 1.0)
  StandardSkillEntry.create(description: "riding - c", number: 1, letter: 'b', points: 1.3)
  StandardSkillEntry.create(description: "riding - 8", number: 1, letter: 'c', points: 1.5)
  StandardSkillEntry.create(description: "riding holding seatpost, one hand", number: 2, letter: 'a', points: 1.3)
  StandardSkillEntry.create(description: "riding holding seatpost, one hand - c", number: 2, letter: 'b', points: 1.6)
  StandardSkillEntry.create(description: "riding holding seatpost, one hand - 8", number: 2, letter: 'c', points: 1.9)
  StandardSkillEntry.create(description: "riding holding seatpost, two hands", number: 2, letter: 'd', points: 1.4)
  StandardSkillEntry.create(description: "riding holding seatpost, two hands - c", number: 2, letter: 'e', points: 1.8)
  StandardSkillEntry.create(description: "riding holding seatpost, two hands - 8", number: 2, letter: 'f', points: 2.0)
  StandardSkillEntry.create(description: "riding bwd", number: 3, letter: 'a', points: 2.5)
  StandardSkillEntry.create(description: "riding bwd - c", number: 3, letter: 'b', points: 3.1)
  StandardSkillEntry.create(description: "riding bwd - 8", number: 3, letter: 'c', points: 3.6)
  StandardSkillEntry.create(description: "seat in front, seat against body", number: 4, letter: 'a', points: 2.0)
  StandardSkillEntry.create(description: "seat in front", number: 4, letter: 'b', points: 2.3)
  StandardSkillEntry.create(description: "seat in front - c", number: 4, letter: 'c', points: 2.9)
  StandardSkillEntry.create(description: "seat in front - 8", number: 4, letter: 'd', points: 3.3)
  StandardSkillEntry.create(description: "seat in front frh, seat against body", number: 4, letter: 'e', points: 3.3)
  StandardSkillEntry.create(description: "seat in front frh", number: 4, letter: 'f', points: 3.7)
  StandardSkillEntry.create(description: "seat in front frh - c", number: 4, letter: 'g', points: 4.3)
  StandardSkillEntry.create(description: "seat in front frh - 8", number: 4, letter: 'h', points: 4.8)
  StandardSkillEntry.create(description: "seat in front bwd, seat against body", number: 5, letter: 'a', points: 3.4)
  StandardSkillEntry.create(description: "seat in front bwd", number: 5, letter: 'b', points: 3.6)
  StandardSkillEntry.create(description: "seat in front bwd - c", number: 5, letter: 'c', points: 4.1)
  StandardSkillEntry.create(description: "seat in front bwd - 8", number: 5, letter: 'd', points: 4.7)
  StandardSkillEntry.create(description: "seat in front bwd frh, seat against body", number: 5, letter: 'e', points: 4.0)
  StandardSkillEntry.create(description: "seat in front bwd frh", number: 5, letter: 'f', points: 4.5)
  StandardSkillEntry.create(description: "seat in front bwd frh - c", number: 5, letter: 'g', points: 5.2)
  StandardSkillEntry.create(description: "seat in back, seat against body", number: 6, letter: 'a', points: 2.2)
  StandardSkillEntry.create(description: "seat in back", number: 6, letter: 'b', points: 2.5)
  StandardSkillEntry.create(description: "seat in back - c", number: 6, letter: 'c', points: 3.1)
  StandardSkillEntry.create(description: "seat in back - 8", number: 6, letter: 'd', points: 3.6)
  StandardSkillEntry.create(description: "seat in back bwd, seat against body", number: 7, letter: 'a', points: 3.5)
  StandardSkillEntry.create(description: "seat in back bwd", number: 7, letter: 'b', points: 3.9)
  StandardSkillEntry.create(description: "seat in back bwd - c", number: 7, letter: 'c', points: 4.5)
  StandardSkillEntry.create(description: "seat in back bwd - 8", number: 7, letter: 'd', points: 5.1)
  StandardSkillEntry.create(description: "seat on side, seat against body", number: 8, letter: 'a', points: 3.4)
  StandardSkillEntry.create(description: "seat on side, seat against body - c", number: 8, letter: 'b', points: 3.2)
  StandardSkillEntry.create(description: "seat on side", number: 8, letter: 'c', points: 4.1)
  StandardSkillEntry.create(description: "seat on side - c", number: 8, letter: 'd', points: 3.9)
  StandardSkillEntry.create(description: "seat on side bwd, seat against body", number: 9, letter: 'a', points: 4.3)
  StandardSkillEntry.create(description: "seat on side bwd", number: 9, letter: 'b', points: 4.6)
  StandardSkillEntry.create(description: "seat on side bwd - c", number: 9, letter: 'c', points: 4.4)
  StandardSkillEntry.create(description: "stomach on seat, 1 hand on seat", number: 10, letter: 'a', points: 2.1)
  StandardSkillEntry.create(description: "stomach on seat", number: 10, letter: 'b', points: 2.3)
  StandardSkillEntry.create(description: "stomach on seat - c", number: 10, letter: 'c', points: 2.9)
  StandardSkillEntry.create(description: "stomach on seat - 8", number: 10, letter: 'd', points: 3.3)
  StandardSkillEntry.create(description: "stomach on seat bwd", number: 11, letter: 'a', points: 3.8)
  StandardSkillEntry.create(description: "stomach on seat bwd - c", number: 11, letter: 'b', points: 4.4)
  StandardSkillEntry.create(description: "stomach on seat bwd - 8", number: 11, letter: 'c', points: 4.9)
  StandardSkillEntry.create(description: "chin on seat, 1 hand on seat", number: 12, letter: 'a', points: 3.5)
  StandardSkillEntry.create(description: "chin on seat", number: 12, letter: 'b', points: 4.0)
  StandardSkillEntry.create(description: "chin on seat - c", number: 12, letter: 'c', points: 4.6)
  StandardSkillEntry.create(description: "chin on seat - 8", number: 12, letter: 'd', points: 5.2)
  StandardSkillEntry.create(description: "chin on seat bwd, 1 hand on seat", number: 13, letter: 'a', points: 4.2)
  StandardSkillEntry.create(description: "chin on seat bwd", number: 13, letter: 'b', points: 4.9)
  StandardSkillEntry.create(description: "chin on seat bwd - c", number: 13, letter: 'c', points: 5.6)
  StandardSkillEntry.create(description: "chin on seat bwd - 8", number: 13, letter: 'd', points: 6.4)
  StandardSkillEntry.create(description: "drag seat in front", number: 14, letter: 'a', points: 4.1)
  StandardSkillEntry.create(description: "drag seat in front - c", number: 14, letter: 'b', points: 4.7)
  StandardSkillEntry.create(description: "drag seat in front - 8", number: 14, letter: 'c', points: 5.3)
  StandardSkillEntry.create(description: "drag seat in front bwd", number: 15, letter: 'a', points: 5.3)
  StandardSkillEntry.create(description: "drag seat in front bwd - c", number: 15, letter: 'b', points: 6.1)
  StandardSkillEntry.create(description: "drag seat in front bwd - 8", number: 15, letter: 'c', points: 6.9)
  StandardSkillEntry.create(description: "drag seat in back", number: 16, letter: 'a', points: 4.3)
  StandardSkillEntry.create(description: "drag seat in back - c", number: 16, letter: 'b', points: 4.9)
  StandardSkillEntry.create(description: "drag seat in back - 8", number: 16, letter: 'c', points: 5.6)
  StandardSkillEntry.create(description: "drag seat in back bwd", number: 17, letter: 'a', points: 6.0)
  StandardSkillEntry.create(description: "drag seat in back bwd - c", number: 17, letter: 'b', points: 6.9)
  StandardSkillEntry.create(description: "drag seat in back bwd - 8", number: 17, letter: 'c', points: 7.8)
  StandardSkillEntry.create(description: "riding sideways, seat against body", number: 18, letter: 'a', points: 5.6)
  StandardSkillEntry.create(description: "riding sideways", number: 18, letter: 'b', points: 5.7)
  StandardSkillEntry.create(description: "riding sideways 1 ft ext, seat against body", number: 18, letter: 'c', points: 6.0)
  StandardSkillEntry.create(description: "riding sideways seat drag", number: 18, letter: 'd', points: 6.3)
  StandardSkillEntry.create(description: "one foot", number: 19, letter: 'a', points: 3.0)
  StandardSkillEntry.create(description: "one foot - c", number: 19, letter: 'b', points: 3.5)
  StandardSkillEntry.create(description: "one foot - 8", number: 19, letter: 'c', points: 3.9)
  StandardSkillEntry.create(description: "one foot ext", number: 19, letter: 'd', points: 3.2)
  StandardSkillEntry.create(description: "one foot ext - c", number: 19, letter: 'e', points: 3.7)
  StandardSkillEntry.create(description: "one foot ext - 8", number: 19, letter: 'f', points: 4.2)
  StandardSkillEntry.create(description: "one foot crossed", number: 19, letter: 'g', points: 3.4)
  StandardSkillEntry.create(description: "one foot crossed - c", number: 19, letter: 'h', points: 3.9)
  StandardSkillEntry.create(description: "one foot crossed - 8", number: 19, letter: 'i', points: 4.4)
  StandardSkillEntry.create(description: "one foot bwd", number: 20, letter: 'a', points: 4.0)
  StandardSkillEntry.create(description: "one foot bwd - c", number: 20, letter: 'b', points: 4.6)
  StandardSkillEntry.create(description: "one foot bwd - 8", number: 20, letter: 'c', points: 5.2)
  StandardSkillEntry.create(description: "one foot ext bwd", number: 20, letter: 'd', points: 4.4)
  StandardSkillEntry.create(description: "one foot ext bwd - c", number: 20, letter: 'e', points: 5.1)
  StandardSkillEntry.create(description: "one foot ext bwd - 8", number: 20, letter: 'f', points: 5.7)
  StandardSkillEntry.create(description: "one foot seat in front against body", number: 21, letter: 'a', points: 3.8)
  StandardSkillEntry.create(description: "one foot seat in front", number: 21, letter: 'b', points: 4.5)
  StandardSkillEntry.create(description: "one foot seat in front - c", number: 21, letter: 'c', points: 5.2)
  StandardSkillEntry.create(description: "one foot seat in front - 8", number: 21, letter: 'd', points: 5.9)
  StandardSkillEntry.create(description: "one foot ext, seat in front against body", number: 21, letter: 'e', points: 4.1)
  StandardSkillEntry.create(description: "one foot ext, seat in front against body - c", number: 21, letter: 'f', points: 4.7)
  StandardSkillEntry.create(description: "one foot seat in front against body bwd", number: 22, letter: 'a', points: 4.7)
  StandardSkillEntry.create(description: "one foot seat in front bwd", number: 22, letter: 'b', points: 5.4)
  StandardSkillEntry.create(description: "one foot seat in front bwd - c", number: 22, letter: 'c', points: 6.2)
  StandardSkillEntry.create(description: "one foot ext, seat in front against body bwd", number: 22, letter: 'd', points: 5.9)
  StandardSkillEntry.create(description: "one foot ext, seat in front against body bwd - c", number: 22, letter: 'e', points: 6.8)
  StandardSkillEntry.create(description: "seat on side, one foot, seat against body", number: 23, letter: 'a', points: 4.0)
  StandardSkillEntry.create(description: "seat on side, one foot", number: 23, letter: 'b', points: 5.0)
  StandardSkillEntry.create(description: "seat on side, one foot - c", number: 23, letter: 'c', points: 4.8)
  StandardSkillEntry.create(description: "seat on side, one foot - 8", number: 23, letter: 'd', points: 6.5)
  StandardSkillEntry.create(description: "seat on side, one foot bwd, seat against body", number: 24, letter: 'a', points: 5.0)
  StandardSkillEntry.create(description: "seat on side, one foot bwd", number: 24, letter: 'b', points: 5.4)
  StandardSkillEntry.create(description: "seat on side, one foot bwd - c", number: 24, letter: 'c', points: 5.1)
  StandardSkillEntry.create(description: "side saddle, hand touching seat", number: 25, letter: 'a', points: 3.5)
  StandardSkillEntry.create(description: "side saddle, hand touching seat - c", number: 25, letter: 'b', points: 4.0)
  StandardSkillEntry.create(description: "side saddle freehand", number: 25, letter: 'c', points: 3.7)
  StandardSkillEntry.create(description: "side saddle freehand - c", number: 25, letter: 'd', points: 4.3)
  StandardSkillEntry.create(description: "side saddle freehand - 8", number: 25, letter: 'e', points: 4.8)
  StandardSkillEntry.create(description: "cross over", number: 26, letter: 'a', points: 4.4)
  StandardSkillEntry.create(description: "cross over - c", number: 26, letter: 'b', points: 4.2)
  StandardSkillEntry.create(description: "cross over - 8", number: 26, letter: 'c', points: 5.7)
  StandardSkillEntry.create(description: "cross over bwd", number: 27, letter: 'a', points: 5.4)
  StandardSkillEntry.create(description: "cross over bwd - c", number: 27, letter: 'b', points: 5.1)
  StandardSkillEntry.create(description: "cross over bwd - 8", number: 27, letter: 'c', points: 7.0)
  StandardSkillEntry.create(description: "side ride", number: 28, letter: 'a', points: 5.9)
  StandardSkillEntry.create(description: "side ride - c", number: 28, letter: 'b', points: 5.6)
  StandardSkillEntry.create(description: "side ride - 8", number: 28, letter: 'c', points: 7.7)
  StandardSkillEntry.create(description: "side ride, one hand", number: 28, letter: 'd', points: 6.2)
  StandardSkillEntry.create(description: "side ride, one hand - c", number: 28, letter: 'e', points: 5.9)
  StandardSkillEntry.create(description: "side ride, one hand - 8", number: 28, letter: 'f', points: 8.1)
  StandardSkillEntry.create(description: "side ride bwd", number: 29, letter: 'a', points: 6.6)
  StandardSkillEntry.create(description: "side ride bwd - c", number: 29, letter: 'b', points: 6.3)
  StandardSkillEntry.create(description: "side ride bwd - 8", number: 29, letter: 'c', points: 8.6)
  StandardSkillEntry.create(description: "side ride bwd, 1 hand", number: 29, letter: 'd', points: 6.8)
  StandardSkillEntry.create(description: "side ride bwd, 1 hand - c", number: 29, letter: 'e', points: 6.5)
  StandardSkillEntry.create(description: "side ride bwd, 1 hand - 8", number: 29, letter: 'f', points: 8.8)
  StandardSkillEntry.create(description: "wheel walk", number: 30, letter: 'a', points: 3.3)
  StandardSkillEntry.create(description: "wheel walk - c", number: 30, letter: 'b', points: 3.8)
  StandardSkillEntry.create(description: "wheel walk - 8", number: 30, letter: 'c', points: 4.3)
  StandardSkillEntry.create(description: "wheel walk bwd", number: 31, letter: 'a', points: 4.4)
  StandardSkillEntry.create(description: "wheel walk bwd - c", number: 31, letter: 'b', points: 5.1)
  StandardSkillEntry.create(description: "wheel walk frame between feet", number: 32, letter: 'a', points: 4.1)
  StandardSkillEntry.create(description: "wheel walk frame between feet - c", number: 32, letter: 'b', points: 4.7)
  StandardSkillEntry.create(description: "wheel walk frame between feet bwd", number: 33, letter: 'a', points: 4.6)
  StandardSkillEntry.create(description: "wheel walk frame between feet bwd - c", number: 33, letter: 'b', points: 5.3)
  StandardSkillEntry.create(description: "wheel walk bwd, feet behind frame", number: 34, letter: 'a', points: 5.0)
  StandardSkillEntry.create(description: "wheel walk bwd, feet behind frame - c", number: 34, letter: 'b', points: 5.8)
  StandardSkillEntry.create(description: "spoke walk bwd, feet behind frame", number: 35, letter: 'a', points: 5.3)
  StandardSkillEntry.create(description: "spoke walk bwd, feet behind frame - c", number: 35, letter: 'b', points: 6.1)
  StandardSkillEntry.create(description: "wheel walk one foot", number: 36, letter: 'a', points: 3.5)
  StandardSkillEntry.create(description: "wheel walk one foot - c", number: 36, letter: 'b', points: 4.3)
  StandardSkillEntry.create(description: "wheel walk one foot - 8", number: 36, letter: 'c', points: 4.8)
  StandardSkillEntry.create(description: "wheel walk one foot ext", number: 36, letter: 'd', points: 4.0)
  StandardSkillEntry.create(description: "wheel walk one foot ext - c", number: 36, letter: 'e', points: 4.6)
  StandardSkillEntry.create(description: "wheel walk one foot ext - 8", number: 36, letter: 'f', points: 5.2)
  StandardSkillEntry.create(description: "ww 1ft crossed", number: 36, letter: 'g', points: 4.6)
  StandardSkillEntry.create(description: "ww 1ft crossed - c", number: 36, letter: 'h', points: 5.3)
  StandardSkillEntry.create(description: "wheel walk bwd one foot", number: 37, letter: 'a', points: 5.4)
  StandardSkillEntry.create(description: "wheel walk bwd one foot - c", number: 37, letter: 'b', points: 6.2)
  StandardSkillEntry.create(description: "wheel walk bwd one foot ext", number: 37, letter: 'c', points: 6.0)
  StandardSkillEntry.create(description: "wheel walk bwd one foot ext - c", number: 37, letter: 'd', points: 6.9)
  StandardSkillEntry.create(description: "koosh koosh", number: 38, letter: 'a', points: 3.9)
  StandardSkillEntry.create(description: "koosh koosh - c", number: 38, letter: 'b', points: 4.5)
  StandardSkillEntry.create(description: "wheel walk bwd one foot behind frame", number: 38, letter: 'c', points: 5.2)
  StandardSkillEntry.create(description: "wheel walk bwd one foot behind frame - c", number: 38, letter: 'd', points: 6.0)
  StandardSkillEntry.create(description: "hand wheel walk", number: 39, letter: 'a', points: 4.7)
  StandardSkillEntry.create(description: "hand wheel walk - c", number: 39, letter: 'b', points: 5.4)
  StandardSkillEntry.create(description: "hand wheel walk feet out", number: 39, letter: 'c', points: 5.8)
  StandardSkillEntry.create(description: "hand wheel walk feet out - c", number: 39, letter: 'd', points: 6.7)
  StandardSkillEntry.create(description: "one hand wheel walk", number: 40, letter: 'a', points: 5.4)
  StandardSkillEntry.create(description: "one hand wheel walk - c", number: 40, letter: 'b', points: 6.2)
  StandardSkillEntry.create(description: "one hand wheel walk feet out", number: 40, letter: 'c', points: 6.5)
  StandardSkillEntry.create(description: "one hand wheel walk feet out - c", number: 40, letter: 'd', points: 7.5)
  StandardSkillEntry.create(description: "hand wheel walk, stomach on seat", number: 41, letter: 'a', points: 4.3)
  StandardSkillEntry.create(description: "hand ww, stomach on seat - c", number: 41, letter: 'b', points: 4.9)
  StandardSkillEntry.create(description: "one hand wheel walk, stomach on seat", number: 42, letter: 'a', points: 5.1)
  StandardSkillEntry.create(description: "one hand ww, stomach on seat - c", number: 42, letter: 'b', points: 5.9)
  StandardSkillEntry.create(description: "wheel walk seat in front", number: 43, letter: 'a', points: 6.3)
  StandardSkillEntry.create(description: "wheel walk seat in front - c", number: 43, letter: 'b', points: 7.2)
  StandardSkillEntry.create(description: "wheel walk seat in front, one foot", number: 43, letter: 'c', points: 5.4)
  StandardSkillEntry.create(description: "wheel walk seat in front, one foot extended", number: 43, letter: 'd', points: 6.2)
  StandardSkillEntry.create(description: "wheel walk seat in front bwd, feet behind frame", number: 44, letter: 'a', points: 6.5)
  StandardSkillEntry.create(description: "ww seat in front bwd, feet behind frame - c", number: 44, letter: 'b', points: 7.5)
  StandardSkillEntry.create(description: "ww seat in front bwd, one foot, foot behind frame", number: 44, letter: 'c', points: 6.5)
  StandardSkillEntry.create(description: "ww seat in front bwd, 1ft ext, foot behind frame", number: 44, letter: 'd', points: 6.7)
  StandardSkillEntry.create(description: "wheel walk seat in back", number: 45, letter: 'a', points: 6.4)
  StandardSkillEntry.create(description: "wheel walk seat in back - c", number: 45, letter: 'b', points: 7.4)
  StandardSkillEntry.create(description: "wheel walk seat in back, one foot extended", number: 45, letter: 'c', points: 6.5)
  StandardSkillEntry.create(description: "seat on side, ww, hand touching seat", number: 46, letter: 'a', points: 5.6)
  StandardSkillEntry.create(description: "seat on side, ww", number: 46, letter: 'b', points: 5.8)
  StandardSkillEntry.create(description: "seat on side, ww - c", number: 46, letter: 'c', points: 6.7)
  StandardSkillEntry.create(description: "seat on side, ww 1ft, hand touching seat", number: 46, letter: 'd', points: 5.3)
  StandardSkillEntry.create(description: "seat on side, ww 1ft", number: 46, letter: 'e', points: 5.6)
  StandardSkillEntry.create(description: "seat on side, ww 1ft - c", number: 46, letter: 'f', points: 6.4)
  StandardSkillEntry.create(description: "seat on side, stand up ww 1ft, hand touching seat", number: 46, letter: 'g', points: 5.2)
  StandardSkillEntry.create(description: "seat on side, stand up ww 1ft", number: 46, letter: 'h', points: 5.6)
  StandardSkillEntry.create(description: "seat on side, stand up ww 1ft - c", number: 46, letter: 'i', points: 6.4)
  StandardSkillEntry.create(description: "seat on side, koosh koosh", number: 47, letter: 'a', points: 5.5)
  StandardSkillEntry.create(description: "seat on side, koosh koosh -c", number: 47, letter: 'b', points: 6.3)
  StandardSkillEntry.create(description: "seat on side, stand up koosh koosh", number: 47, letter: 'c', points: 5.6)
  StandardSkillEntry.create(description: "seat on side, stand up koosh koosh -c", number: 47, letter: 'd', points: 6.4)
  StandardSkillEntry.create(description: "sideways wheel walk", number: 48, letter: 'a', points: 5.4)
  StandardSkillEntry.create(description: "sideways wheel walk - c", number: 48, letter: 'b', points: 6.2)
  StandardSkillEntry.create(description: "sideways wheel walk, one foot", number: 49, letter: 'a', points: 5.6)
  StandardSkillEntry.create(description: "sideways wheel walk, one foot - c", number: 49, letter: 'b', points: 6.4)
  StandardSkillEntry.create(description: "sideways wheel walk, one foot on seat", number: 49, letter: 'c', points: 5.8)
  StandardSkillEntry.create(description: "sideways ww, sitting on seat, 1 hand", number: 50, letter: 'a', points: 6.1)
  StandardSkillEntry.create(description: "sideways ww, sitting on seat, frh", number: 50, letter: 'b', points: 6.3)
  StandardSkillEntry.create(description: "sideways ww, sitting on seat, frh - c", number: 50, letter: 'c', points: 7.2)
  StandardSkillEntry.create(description: "sideways ww, sitting on seat, frh, 1 ft", number: 50, letter: 'd', points: 6.5)
  StandardSkillEntry.create(description: "sideways ww, sitting on seat, frh, 1 ft ext", number: 50, letter: 'e', points: 6.7)
  StandardSkillEntry.create(description: "stand up ww 1 ft", number: 51, letter: 'a', points: 4.2)
  StandardSkillEntry.create(description: "stand up ww 1 ft - c", number: 51, letter: 'b', points: 4.8)
  StandardSkillEntry.create(description: "stand up koosh koosh", number: 52, letter: 'a', points: 4.8)
  StandardSkillEntry.create(description: "stand up koosh koosh - c", number: 52, letter: 'b', points: 5.5)
  StandardSkillEntry.create(description: "stand up ww bwd 1ft", number: 52, letter: 'c', points: 6.0)
  StandardSkillEntry.create(description: "stand up ww bwd 1ft -c", number: 52, letter: 'd', points: 6.9)
  StandardSkillEntry.create(description: "gliding", number: 53, letter: 'a', points: 3.9)
  StandardSkillEntry.create(description: "gliding - c", number: 53, letter: 'b', points: 4.7)
  StandardSkillEntry.create(description: "gliding, foot on frame", number: 53, letter: 'c', points: 3.9)
  StandardSkillEntry.create(description: "gliding, foot on frame - c", number: 53, letter: 'd', points: 4.7)
  StandardSkillEntry.create(description: "gliding, leg ext", number: 53, letter: 'e', points: 4.2)
  StandardSkillEntry.create(description: "gliding, leg ext - c", number: 53, letter: 'f', points: 5.0)
  StandardSkillEntry.create(description: "gliding bwd foot behind frame", number: 54, letter: 'a', points: 5.2)
  StandardSkillEntry.create(description: "gliding bwd foot behind frame - c", number: 54, letter: 'b', points: 6.2)
  StandardSkillEntry.create(description: "gliding bwd foot on frame", number: 54, letter: 'c', points: 5.1)
  StandardSkillEntry.create(description: "gliding bwd foot on frame -c", number: 54, letter: 'd', points: 6.1)
  StandardSkillEntry.create(description: "gliding bwd foot on frame, leg ext", number: 54, letter: 'e', points: 5.7)
  StandardSkillEntry.create(description: "gliding bwd foot on frame, leg ext -c", number: 54, letter: 'f', points: 6.8)
  StandardSkillEntry.create(description: "coasting, leg ext", number: 55, letter: 'a', points: 5.3)
  StandardSkillEntry.create(description: "coasting, leg ext - c", number: 55, letter: 'b', points: 6.1)
  StandardSkillEntry.create(description: "coasting, leg ext - 8", number: 55, letter: 'c', points: 6.9)
  StandardSkillEntry.create(description: "coasting, feet in", number: 55, letter: 'd', points: 5.3)
  StandardSkillEntry.create(description: "coasting, feet in - c", number: 55, letter: 'e', points: 6.1)
  StandardSkillEntry.create(description: "coasting, feet in - 8", number: 55, letter: 'f', points: 6.9)
  StandardSkillEntry.create(description: "coasting bwd, leg ext", number: 56, letter: 'a', points: 6.2)
  StandardSkillEntry.create(description: "coasting bwd, leg ext - c", number: 56, letter: 'b', points: 7.1)
  StandardSkillEntry.create(description: "coasting bwd, leg ext - 8", number: 56, letter: 'c', points: 8.1)
  StandardSkillEntry.create(description: "coasting bwd, feet in", number: 56, letter: 'd', points: 6.0)
  StandardSkillEntry.create(description: "coasting bwd, feet in - c", number: 56, letter: 'e', points: 7.0)
  StandardSkillEntry.create(description: "coasting bwd, feet in - 8", number: 56, letter: 'f', points: 7.8)
  StandardSkillEntry.create(description: "stand up glide", number: 57, letter: 'a', points: 5.4)
  StandardSkillEntry.create(description: "stand up glide - c", number: 57, letter: 'b', points: 6.5)
  StandardSkillEntry.create(description: "stand up glide, foot on frame", number: 57, letter: 'c', points: 5.4)
  StandardSkillEntry.create(description: "stand up glide, foot on frame - c", number: 57, letter: 'd', points: 6.5)
  StandardSkillEntry.create(description: "stand up glide 1ft ext, 1 hand on seat", number: 57, letter: 'e', points: 6.3)
  StandardSkillEntry.create(description: "stand up glide 1ft ext", number: 57, letter: 'f', points: 6.6)
  StandardSkillEntry.create(description: "stand up glide 1ft ext -c", number: 57, letter: 'g', points: 7.9)
  StandardSkillEntry.create(description: "stand up glide bwd", number: 58, letter: 'a', points: 6.7)
  StandardSkillEntry.create(description: "stand up glide bwd - c", number: 58, letter: 'b', points: 8.0)
  StandardSkillEntry.create(description: "stand up glide bwd, foot on frame", number: 58, letter: 'c', points: 6.7)
  StandardSkillEntry.create(description: "stand up glide bwd, foot on frame - c", number: 58, letter: 'd', points: 8.0)
  StandardSkillEntry.create(description: "stand up glide bwd 1ft ext, 1 hand", number: 58, letter: 'e', points: 7.1)
  StandardSkillEntry.create(description: "stand up glide bwd 1ft ext", number: 58, letter: 'f', points: 7.4)
  StandardSkillEntry.create(description: "stand up glide bwd 1ft ext - c", number: 58, letter: 'g', points: 8.9)
  StandardSkillEntry.create(description: "stand up coast", number: 59, letter: 'a', points: 7.0)
  StandardSkillEntry.create(description: "stand up coast - c", number: 59, letter: 'b', points: 8.4)
  StandardSkillEntry.create(description: "stand up coast - 8", number: 59, letter: 'c', points: 9.5)
  StandardSkillEntry.create(description: "riding to seat in front", number: 101, letter: 'a', points: 1.3)
  StandardSkillEntry.create(description: "riding to stomach on seat", number: 101, letter: 'b', points: 1.5)
  StandardSkillEntry.create(description: "seat in front to riding", number: 102, letter: 'a', points: 1.5)
  StandardSkillEntry.create(description: "stomach on seat to riding", number: 102, letter: 'b', points: 1.6)
  StandardSkillEntry.create(description: "riding to seat in back", number: 103, letter: 'a', points: 1.6)
  StandardSkillEntry.create(description: "seat in back to riding", number: 104, letter: 'a', points: 1.7)
  StandardSkillEntry.create(description: "ww to pedals", number: 105, letter: 'a', points: 2.8)
  StandardSkillEntry.create(description: "ww to riding 1 ft", number: 105, letter: 'b', points: 3.1)
  StandardSkillEntry.create(description: "gliding to pedals", number: 105, letter: 'c', points: 3.3)
  StandardSkillEntry.create(description: "gliding to riding 1 ft", number: 105, letter: 'd', points: 3.5)
  StandardSkillEntry.create(description: "ww 1ft to pedals", number: 105, letter: 'e', points: 3.0)
  StandardSkillEntry.create(description: "pick up seat in front", number: 106, letter: 'a', points: 4.0)
  StandardSkillEntry.create(description: "pick up seat in front with toe", number: 106, letter: 'b', points: 4.5)
  StandardSkillEntry.create(description: "pick up seat in front free foot", number: 106, letter: 'c', points: 4.2)
  StandardSkillEntry.create(description: "pick up seat in back", number: 107, letter: 'a', points: 4.0)
  StandardSkillEntry.create(description: "pick up seat in back with heel", number: 107, letter: 'b', points: 4.0)
  StandardSkillEntry.create(description: "pick up seat in back free foot", number: 107, letter: 'c', points: 4.8)
  StandardSkillEntry.create(description: "seat in front to side ride", number: 108, letter: 'a', points: 5.0)
  StandardSkillEntry.create(description: "side ride to seat in front", number: 109, letter: 'a', points: 5.2)
  StandardSkillEntry.create(description: "side ride to hopping on wheel", number: 110, letter: 'a', points: 4.7)
  StandardSkillEntry.create(description: "side ride to sideways wheel walk", number: 110, letter: 'b', points: 5.3)
  StandardSkillEntry.create(description: "idling to stand up ww", number: 111, letter: 'a', points: 3.7)
  StandardSkillEntry.create(description: "idling to stand up ww frh", number: 111, letter: 'b', points: 3.9)
  StandardSkillEntry.create(description: "hopping to stand up ww", number: 111, letter: 'c', points: 3.9)
  StandardSkillEntry.create(description: "hopping to stand up ww frh", number: 111, letter: 'd', points: 4.1)
  StandardSkillEntry.create(description: "stillstand to stand up ww", number: 111, letter: 'e', points: 4.3)
  StandardSkillEntry.create(description: "stillstand to stand up ww frh", number: 111, letter: 'f', points: 4.5)
  StandardSkillEntry.create(description: "riding to stand up ww", number: 111, letter: 'g', points: 4.0)
  StandardSkillEntry.create(description: "riding to stand up ww frh", number: 111, letter: 'h', points: 4.2)
  StandardSkillEntry.create(description: "riding bwd to stand up koosh koosh", number: 111, letter: 'i', points: 4.2)
  StandardSkillEntry.create(description: "riding bwd to stand up koosh koosh frh", number: 111, letter: 'j', points: 4.4)
  StandardSkillEntry.create(description: "1 ft to stand up glide", number: 112, letter: 'a', points: 4.0)
  StandardSkillEntry.create(description: "1 ft to stand up glide frh", number: 112, letter: 'b', points: 4.1)
  StandardSkillEntry.create(description: "gliding to stand up glide", number: 112, letter: 'c', points: 3.8)
  StandardSkillEntry.create(description: "gliding to stand up glide frh", number: 112, letter: 'd', points: 3.9)
  StandardSkillEntry.create(description: "riding to stand up glide", number: 112, letter: 'e', points: 4.2)
  StandardSkillEntry.create(description: "riding to stand up glide frh", number: 112, letter: 'f', points: 4.3)
  StandardSkillEntry.create(description: "1 ft bwd to stand up glide bwd", number: 113, letter: 'a', points: 5.1)
  StandardSkillEntry.create(description: "1 ft bwd to stand up glide bwd frh", number: 113, letter: 'b', points: 5.3)
  StandardSkillEntry.create(description: "gliding bwd to stand up glide bwd", number: 113, letter: 'c', points: 4.9)
  StandardSkillEntry.create(description: "gliding bwd to stand up glide bwd frh", number: 113, letter: 'd', points: 5.1)
  StandardSkillEntry.create(description: "riding bwd to stand up glide bwd", number: 113, letter: 'e', points: 5.3)
  StandardSkillEntry.create(description: "riding bwd to stand up glide bwd frh", number: 113, letter: 'f', points: 5.5)
  StandardSkillEntry.create(description: "stand up ww to hop on wheel frh", number: 114, letter: 'a', points: 3.6)
  StandardSkillEntry.create(description: "hop on wheel frh to stand up ww", number: 114, letter: 'b', points: 3.6)
  StandardSkillEntry.create(description: "ww to crossover", number: 115, letter: 'a', points: 3.7)
  StandardSkillEntry.create(description: "ww 1ft to crossover", number: 115, letter: 'b', points: 3.8)
  StandardSkillEntry.create(description: "gliding to crossover", number: 115, letter: 'c', points: 4.2)
  StandardSkillEntry.create(description: "crossover to ww", number: 116, letter: 'a', points: 3.7)
  StandardSkillEntry.create(description: "crossover to ww 1ft", number: 116, letter: 'b', points: 3.8)
  StandardSkillEntry.create(description: "riding turn 90", number: 151, letter: 'a', points: 1.3)
  StandardSkillEntry.create(description: "riding turn 180", number: 151, letter: 'b', points: 1.7)
  StandardSkillEntry.create(description: "riding turn 360", number: 151, letter: 'c', points: 2.2)
  StandardSkillEntry.create(description: "bwd riding turn 90", number: 152, letter: 'a', points: 2.3)
  StandardSkillEntry.create(description: "bwd riding turn 180", number: 152, letter: 'b', points: 2.7)
  StandardSkillEntry.create(description: "bwd riding turn 360", number: 152, letter: 'c', points: 3.5)
  StandardSkillEntry.create(description: "stand up full turn, arms in", number: 153, letter: 'a', points: 4.6)
  StandardSkillEntry.create(description: "stand up full turn", number: 153, letter: 'b', points: 4.8)
  StandardSkillEntry.create(description: "stand up 1.5 turns, arms in", number: 153, letter: 'c', points: 4.9)
  StandardSkillEntry.create(description: "stand up 1.5 turns", number: 153, letter: 'd', points: 5.1)
  StandardSkillEntry.create(description: "stand up 2 turns, arms in", number: 153, letter: 'e', points: 5.3)
  StandardSkillEntry.create(description: "stand up 2 turns", number: 153, letter: 'f', points: 5.5)
  StandardSkillEntry.create(description: "stand up 2.5 turns, arms in", number: 153, letter: 'g', points: 5.8)
  StandardSkillEntry.create(description: "stand up 2.5 turns", number: 153, letter: 'h', points: 6.0)
  StandardSkillEntry.create(description: "stand up 3 turns, arms in", number: 153, letter: 'i', points: 6.3)
  StandardSkillEntry.create(description: "stand up 3 turns", number: 153, letter: 'j', points: 6.5)
  StandardSkillEntry.create(description: "back turn", number: 154, letter: 'a', points: 2.6)
  StandardSkillEntry.create(description: "back turn seat in front, touching body", number: 154, letter: 'b', points: 3.0)
  StandardSkillEntry.create(description: "back turn seat in front", number: 154, letter: 'c', points: 3.2)
  StandardSkillEntry.create(description: "back turn seat in back, touching body", number: 154, letter: 'd', points: 3.3)
  StandardSkillEntry.create(description: "back turn seat in back", number: 154, letter: 'e', points: 3.8)
  StandardSkillEntry.create(description: "back turn, 1ft", number: 154, letter: 'f', points: 3.5)
  StandardSkillEntry.create(description: "front turn", number: 155, letter: 'a', points: 3.0)
  StandardSkillEntry.create(description: "front turn seat in front, touching body", number: 155, letter: 'b', points: 3.2)
  StandardSkillEntry.create(description: "front turn seat in front", number: 155, letter: 'c', points: 3.4)
  StandardSkillEntry.create(description: "front turn seat in back, touching body", number: 155, letter: 'd', points: 3.4)
  StandardSkillEntry.create(description: "front turn seat in back", number: 155, letter: 'e', points: 3.9)
  StandardSkillEntry.create(description: "front turn, 1ft", number: 155, letter: 'f', points: 3.7)
  StandardSkillEntry.create(description: "stand up back turn, arms in", number: 156, letter: 'a', points: 5.2)
  StandardSkillEntry.create(description: "stand up back turn", number: 156, letter: 'b', points: 5.4)
  StandardSkillEntry.create(description: "stand up front turn, arms in", number: 157, letter: 'a', points: 5.3)
  StandardSkillEntry.create(description: "stand up front turn", number: 157, letter: 'b', points: 5.5)
  StandardSkillEntry.create(description: "spin", number: 158, letter: 'a', points: 3.1)
  StandardSkillEntry.create(description: "spin 1ft", number: 158, letter: 'b', points: 3.5)
  StandardSkillEntry.create(description: "spin 1ft ext", number: 158, letter: 'c', points: 3.7)
  StandardSkillEntry.create(description: "backward spin", number: 159, letter: 'a', points: 4.0)
  StandardSkillEntry.create(description: "backward spin 1ft", number: 159, letter: 'b', points: 4.3)
  StandardSkillEntry.create(description: "backward spin 1ft ext", number: 159, letter: 'c', points: 4.7)
  StandardSkillEntry.create(description: "toe point spin", number: 160, letter: 'a', points: 3.6)
  StandardSkillEntry.create(description: "toe point spin frh", number: 160, letter: 'b', points: 3.7)
  StandardSkillEntry.create(description: "1 ft spin, hand holding foot", number: 160, letter: 'c', points: 3.7)
  StandardSkillEntry.create(description: "toe point bwd spin", number: 161, letter: 'a', points: 4.3)
  StandardSkillEntry.create(description: "toe point bwd spin frh", number: 161, letter: 'b', points: 4.5)
  StandardSkillEntry.create(description: "1 ft spin bwd, hand holding foot", number: 161, letter: 'c', points: 5.0)
  StandardSkillEntry.create(description: "cross over toe point spin", number: 162, letter: 'a', points: 4.0)
  StandardSkillEntry.create(description: "cross over spin", number: 162, letter: 'b', points: 3.9)
  StandardSkillEntry.create(description: "cross over spin bwd", number: 163, letter: 'a', points: 4.4)
  StandardSkillEntry.create(description: "spin seat in front, seat against body", number: 164, letter: 'a', points: 3.5)
  StandardSkillEntry.create(description: "spin seat in front", number: 164, letter: 'b', points: 3.7)
  StandardSkillEntry.create(description: "spin seat in back, seat against body", number: 165, letter: 'a', points: 3.6)
  StandardSkillEntry.create(description: "spin seat in back", number: 165, letter: 'b', points: 3.9)
  StandardSkillEntry.create(description: "spin seat on side, seat touching body", number: 166, letter: 'a', points: 3.4)
  StandardSkillEntry.create(description: "spin seat on side", number: 166, letter: 'b', points: 3.8)
  StandardSkillEntry.create(description: "pirouette, arms in", number: 167, letter: 'a', points: 3.9)
  StandardSkillEntry.create(description: "pirouette", number: 167, letter: 'b', points: 4.7)
  StandardSkillEntry.create(description: "backward pirouette, arms in", number: 168, letter: 'a', points: 5.2)
  StandardSkillEntry.create(description: "backward pirouette", number: 168, letter: 'b', points: 5.5)
  StandardSkillEntry.create(description: "pirouette seat in front, against bdy, arm in", number: 169, letter: 'a', points: 4.0)
  StandardSkillEntry.create(description: "pirouette seat in front, seat against body", number: 169, letter: 'b', points: 4.7)
  StandardSkillEntry.create(description: "pirouette seat in front, arm in", number: 169, letter: 'c', points: 4.2)
  StandardSkillEntry.create(description: "pirouette seat in front", number: 169, letter: 'd', points: 4.9)
  StandardSkillEntry.create(description: "pirouette seat in back, against bdy, arm in", number: 170, letter: 'a', points: 4.1)
  StandardSkillEntry.create(description: "pirouette seat in back, seat against body", number: 170, letter: 'b', points: 4.8)
  StandardSkillEntry.create(description: "pirouette seat in back, arm in", number: 170, letter: 'c', points: 4.3)
  StandardSkillEntry.create(description: "pirouette seat in back", number: 170, letter: 'd', points: 5.0)
  StandardSkillEntry.create(description: "hop-twist 90", number: 201, letter: 'a', points: 2.3)
  StandardSkillEntry.create(description: "hop-twist 180", number: 201, letter: 'b', points: 2.8)
  StandardSkillEntry.create(description: "hop-twist 360", number: 201, letter: 'c', points: 4.1)
  StandardSkillEntry.create(description: "hop-twist freehand  90", number: 201, letter: 'd', points: 2.5)
  StandardSkillEntry.create(description: "hop-twist freehand 180", number: 201, letter: 'e', points: 3.0)
  StandardSkillEntry.create(description: "hop-twist freehand 360", number: 201, letter: 'f', points: 4.5)
  StandardSkillEntry.create(description: "riding hoptwist 90", number: 202, letter: 'a', points: 2.5)
  StandardSkillEntry.create(description: "riding hoptwist 180", number: 202, letter: 'b', points: 3.0)
  StandardSkillEntry.create(description: "riding hoptwist 360", number: 202, letter: 'c', points: 4.1)
  StandardSkillEntry.create(description: "riding hoptwist freehand 90", number: 202, letter: 'd', points: 2.6)
  StandardSkillEntry.create(description: "riding hoptwist freehand 180", number: 202, letter: 'e', points: 3.5)
  StandardSkillEntry.create(description: "riding hoptwist freehand 360", number: 202, letter: 'f', points: 4.6)
  StandardSkillEntry.create(description: "hoptwist on wheel 90", number: 203, letter: 'a', points: 3.1)
  StandardSkillEntry.create(description: "hoptwist on wheel 180", number: 203, letter: 'b', points: 3.6)
  StandardSkillEntry.create(description: "hoptwist on wheel freehanded 90", number: 203, letter: 'c', points: 3.7)
  StandardSkillEntry.create(description: "hoptwist on wheel freehanded 180", number: 203, letter: 'd', points: 3.9)
  StandardSkillEntry.create(description: "hop over", number: 204, letter: 'a', points: 2.7)
  StandardSkillEntry.create(description: "sideways hop over", number: 204, letter: 'b', points: 2.6)
  StandardSkillEntry.create(description: "hop over, seat in front", number: 204, letter: 'c', points: 3.1)
  StandardSkillEntry.create(description: "sideways hop over, seat in front, against body", number: 204, letter: 'd', points: 3.0)
  StandardSkillEntry.create(description: "sideways hop over, seat in front", number: 204, letter: 'e', points: 3.3)
  StandardSkillEntry.create(description: "sideways hop over, hopping on wheel", number: 204, letter: 'f', points: 3.3)
  StandardSkillEntry.create(description: "sideways hop over, stand up hopping on wheel frh", number: 204, letter: 'g', points: 3.8)
  StandardSkillEntry.create(description: "wheel grab", number: 205, letter: 'a', points: 1.3)
  StandardSkillEntry.create(description: "wheel grab, 1ft ext", number: 205, letter: 'b', points: 2.2)
  StandardSkillEntry.create(description: "wheel grab, 2ft ext", number: 205, letter: 'c', points: 3.5)
  StandardSkillEntry.create(description: "wheel grab seat in front", number: 205, letter: 'd', points: 3.1)
  StandardSkillEntry.create(description: "wheel grab seat in front, 1ft ext", number: 205, letter: 'e', points: 3.4)
  StandardSkillEntry.create(description: "wheel grab seat in front, 2ft ext", number: 205, letter: 'f', points: 4.0)
  StandardSkillEntry.create(description: "wheel grab seat in front, 2ft ext to back", number: 205, letter: 'g', points: 4.8)
  StandardSkillEntry.create(description: "bounce seat, riding", number: 206, letter: 'a', points: 3.2)
  StandardSkillEntry.create(description: "bounce seat, idling", number: 206, letter: 'b', points: 3.4)
  StandardSkillEntry.create(description: "bounce seat, hopping", number: 206, letter: 'c', points: 3.0)
  StandardSkillEntry.create(description: "bounce seat in back, riding", number: 206, letter: 'd', points: 3.7)
  StandardSkillEntry.create(description: "bounce seat in back, idling", number: 206, letter: 'e', points: 4.0)
  StandardSkillEntry.create(description: "bounce seat in back, hopping", number: 206, letter: 'f', points: 3.7)
  StandardSkillEntry.create(description: "touch seat on floor", number: 207, letter: 'a', points: 3.1)
  StandardSkillEntry.create(description: "touch seat two times on floor", number: 207, letter: 'b', points: 3.3)
  StandardSkillEntry.create(description: "touch seat three times on floor", number: 207, letter: 'c', points: 3.4)
  StandardSkillEntry.create(description: "touch the floor", number: 208, letter: 'a', points: 2.5)
  StandardSkillEntry.create(description: "touch the floor with both hands", number: 208, letter: 'b', points: 3.5)
  StandardSkillEntry.create(description: "touch the floor, seat in front", number: 209, letter: 'a', points: 3.0)
  StandardSkillEntry.create(description: "seat drop", number: 210, letter: 'a', points: 3.3)
  StandardSkillEntry.create(description: "seat drop, twist 90", number: 210, letter: 'b', points: 3.5)
  StandardSkillEntry.create(description: "crank idle kick, seat against body", number: 211, letter: 'a', points: 3.3)
  StandardSkillEntry.create(description: "crank idle kick", number: 211, letter: 'b', points: 3.5)
  StandardSkillEntry.create(description: "crank idle kick, seat against body, high", number: 211, letter: 'c', points: 3.9)
  StandardSkillEntry.create(description: "crank idle kick, high", number: 211, letter: 'd', points: 4.3)
  StandardSkillEntry.create(description: "hop on wheel kick", number: 212, letter: 'a', points: 3.2)
  StandardSkillEntry.create(description: "hop on wheel kick, 2 feet", number: 212, letter: 'b', points: 3.6)
  StandardSkillEntry.create(description: "pedals to hopping on wheel", number: 213, letter: 'a', points: 2.9)
  StandardSkillEntry.create(description: "pedals to hopping on wheel, riding", number: 213, letter: 'b', points: 3.4)
  StandardSkillEntry.create(description: "wheel walk to hopping on wheel", number: 213, letter: 'c', points: 3.8)
  StandardSkillEntry.create(description: "pedals to stand up hopping on wheel, frh", number: 213, letter: 'd', points: 3.5)
  StandardSkillEntry.create(description: "pedals 270 to hopping on wheel", number: 213, letter: 'e', points: 4.0)
  StandardSkillEntry.create(description: "pedals 450 to hopping on wheel", number: 213, letter: 'f', points: 5.3)
  StandardSkillEntry.create(description: "pedals to sideways wheel walk", number: 213, letter: 'g', points: 3.4)
  StandardSkillEntry.create(description: "pedals 270 to sideways wheel walk", number: 213, letter: 'h', points: 4.7)
  StandardSkillEntry.create(description: "pedals 450 to sideways wheel walk", number: 213, letter: 'i', points: 6.0)
  StandardSkillEntry.create(description: "hopping on wheel to pedals", number: 214, letter: 'a', points: 3.4)
  StandardSkillEntry.create(description: "hopping on wheel to pedals, step down", number: 214, letter: 'b', points: 3.4)
  StandardSkillEntry.create(description: "hopping on wheel to wheel walk", number: 214, letter: 'c', points: 3.3)
  StandardSkillEntry.create(description: "stand up hopping on wheel freehanded to pedals", number: 214, letter: 'd', points: 4.0)
  StandardSkillEntry.create(description: "hopping on wheel 270 to pedals", number: 214, letter: 'e', points: 4.2)
  StandardSkillEntry.create(description: "hopping on wheel 450 to pedals", number: 214, letter: 'f', points: 5.8)
  StandardSkillEntry.create(description: "sideways wheel walk to pedals", number: 214, letter: 'g', points: 3.9)
  StandardSkillEntry.create(description: "sideways wheel walk 270 to pedals", number: 214, letter: 'h', points: 6.0)
  StandardSkillEntry.create(description: "180 uni spin", number: 215, letter: 'a', points: 3.6)
  StandardSkillEntry.create(description: "360 uni spin", number: 215, letter: 'b', points: 4.6)
  StandardSkillEntry.create(description: "540 uni spin", number: 215, letter: 'c', points: 5.7)
  StandardSkillEntry.create(description: "720 uni spin", number: 215, letter: 'd', points: 6.8)
  StandardSkillEntry.create(description: "180 uni spin to seat in front", number: 215, letter: 'e', points: 3.6)
  StandardSkillEntry.create(description: "360 uni spin to seat in front", number: 215, letter: 'f', points: 4.6)
  StandardSkillEntry.create(description: "540 uni spin to seat in front", number: 215, letter: 'g', points: 5.7)
  StandardSkillEntry.create(description: "180 uni spin to idling one foot", number: 215, letter: 'h', points: 4.0)
  StandardSkillEntry.create(description: "360 uni spin to idling one foot", number: 215, letter: 'i', points: 5.0)
  StandardSkillEntry.create(description: "540 uni spin to idling one foot", number: 215, letter: 'j', points: 6.2)
  StandardSkillEntry.create(description: "180 uni spin to idling 1 ft seat in front", number: 215, letter: 'k', points: 4.7)
  StandardSkillEntry.create(description: "360 uni spin to idling 1 ft seat in front", number: 215, letter: 'l', points: 5.7)
  StandardSkillEntry.create(description: "riding 180? uni spin", number: 215, letter: 'm', points: 3.9)
  StandardSkillEntry.create(description: "riding 360? uni spin", number: 215, letter: 'n', points: 4.9)
  StandardSkillEntry.create(description: "180 uni spin to wheel walk", number: 216, letter: 'a', points: 4.3)
  StandardSkillEntry.create(description: "360 uni spin to wheel walk", number: 216, letter: 'b', points: 5.3)
  StandardSkillEntry.create(description: "180 uni spin to wheel walk one foot", number: 216, letter: 'c', points: 4.5)
  StandardSkillEntry.create(description: "360 uni spin to wheel walk one foot", number: 216, letter: 'd', points: 5.5)
  StandardSkillEntry.create(description: "180 uni spin to stand up hopping on wheel frh", number: 217, letter: 'a', points: 4.5)
  StandardSkillEntry.create(description: "360 uni spin to stand up hopping on wheel frh", number: 217, letter: 'b', points: 5.5)
  StandardSkillEntry.create(description: "180 uni spin on wheel", number: 218, letter: 'a', points: 3.8)
  StandardSkillEntry.create(description: "360 uni spin on wheel", number: 218, letter: 'b', points: 4.8)
  StandardSkillEntry.create(description: "crankflip, feet on pedals", number: 219, letter: 'a', points: 3.8)
  StandardSkillEntry.create(description: "crankflip", number: 219, letter: 'b', points: 5.1)
  StandardSkillEntry.create(description: "double crankflip", number: 219, letter: 'c', points: 5.6)
  StandardSkillEntry.create(description: "triple crankflip", number: 219, letter: 'd', points: 6.1)
  StandardSkillEntry.create(description: "crankflip, seat in front", number: 219, letter: 'e', points: 5.2)
  StandardSkillEntry.create(description: "double crankflip, seat in front", number: 219, letter: 'f', points: 5.7)
  StandardSkillEntry.create(description: "triple crankflip, seat in front", number: 219, letter: 'g', points: 6.2)
  StandardSkillEntry.create(description: "crankflip 180 unispin", number: 220, letter: 'a', points: 5.5)
  StandardSkillEntry.create(description: "crankflip 360 unispin", number: 220, letter: 'b', points: 6.5)
  StandardSkillEntry.create(description: "crankflip 540 unispin", number: 220, letter: 'c', points: 7.5)
  StandardSkillEntry.create(description: "double crankflip 180 unispin", number: 220, letter: 'd', points: 5.9)
  StandardSkillEntry.create(description: "double crankflip 360 unispin", number: 220, letter: 'e', points: 6.9)
  StandardSkillEntry.create(description: "double crankflip 540 unispin", number: 220, letter: 'f', points: 7.9)
  StandardSkillEntry.create(description: "crank flip, standing on frame", number: 221, letter: 'a', points: 4.4)
  StandardSkillEntry.create(description: "leg around, riding to riding", number: 222, letter: 'a', points: 3.3)
  StandardSkillEntry.create(description: "leg around twice, riding to riding", number: 222, letter: 'b', points: 4.4)
  StandardSkillEntry.create(description: "leg around, riding to seat on side, 1 hand", number: 222, letter: 'c', points: 3.4)
  StandardSkillEntry.create(description: "leg around, riding to seat on side", number: 222, letter: 'd', points: 3.0)
  StandardSkillEntry.create(description: "leg around, riding to crank idle, 1 hand", number: 222, letter: 'e', points: 3.6)
  StandardSkillEntry.create(description: "leg around, riding to crank idle", number: 222, letter: 'f', points: 3.2)
  StandardSkillEntry.create(description: "leg around, riding to crank idle, rev", number: 222, letter: 'g', points: 3.3)
  StandardSkillEntry.create(description: "leg around, riding to seat in back", number: 222, letter: 'h', points: 3.6)
  StandardSkillEntry.create(description: "leg around, seat on side to riding", number: 223, letter: 'a', points: 2.5)
  StandardSkillEntry.create(description: "leg around, seat on side to crank idle", number: 223, letter: 'b', points: 2.6)
  StandardSkillEntry.create(description: "leg around, seat on side to seat in front", number: 223, letter: 'c', points: 3.2)
  StandardSkillEntry.create(description: "leg around, seat on side to seat in front, rev", number: 223, letter: 'd', points: 3.2)
  StandardSkillEntry.create(description: "leg around, seat on side to side hopping", number: 223, letter: 'e', points: 3.4)
  StandardSkillEntry.create(description: "leg around, crank idle to riding, 1 hand", number: 224, letter: 'a', points: 2.6)
  StandardSkillEntry.create(description: "leg around, crank idle to riding, frh", number: 224, letter: 'b', points: 3.1)
  StandardSkillEntry.create(description: "leg around, crank idle to 1ft idle", number: 224, letter: 'c', points: 3.1)
  StandardSkillEntry.create(description: "leg around, crank idle to seat on side", number: 224, letter: 'd', points: 2.6)
  StandardSkillEntry.create(description: "leg around, crank idle to seat in front", number: 224, letter: 'e', points: 3.4)
  StandardSkillEntry.create(description: "leg around, crank idle to crank idle", number: 224, letter: 'f', points: 3.8)
  StandardSkillEntry.create(description: "crank idle to side hopping", number: 224, letter: 'g', points: 3.8)
  StandardSkillEntry.create(description: "crank idle to hop on wheel", number: 224, letter: 'h', points: 3.9)
  StandardSkillEntry.create(description: "crank idle to hop on wheel, jump", number: 224, letter: 'i', points: 4.1)
  StandardSkillEntry.create(description: "leg around, seat in front to riding", number: 225, letter: 'a', points: 2.7)
  StandardSkillEntry.create(description: "leg around twice, seat in front to riding", number: 225, letter: 'b', points: 3.9)
  StandardSkillEntry.create(description: "leg around, seat in front to seat in front", number: 225, letter: 'c', points: 3.4)
  StandardSkillEntry.create(description: "leg around, seat in front to seat on side", number: 225, letter: 'd', points: 3.0)
  StandardSkillEntry.create(description: "leg around, seat in front to crank idle", number: 225, letter: 'e', points: 3.2)
  StandardSkillEntry.create(description: "leg around, seat in front to seat in back", number: 225, letter: 'f', points: 3.4)
  StandardSkillEntry.create(description: "leg around, seat in back to riding", number: 226, letter: 'a', points: 3.7)
  StandardSkillEntry.create(description: "leg around twice, seat in back to riding", number: 226, letter: 'b', points: 4.4)
  StandardSkillEntry.create(description: "step around", number: 227, letter: 'a', points: 3.9)
  StandardSkillEntry.create(description: "jump around", number: 227, letter: 'b', points: 4.9)
  StandardSkillEntry.create(description: "inverse", number: 227, letter: 'c', points: 4.8)
  StandardSkillEntry.create(description: "180 unispin, 180 hoptwist", number: 228, letter: 'a', points: 5.1)
  StandardSkillEntry.create(description: "360 unispin, 180 hoptwist", number: 228, letter: 'b', points: 5.4)
  StandardSkillEntry.create(description: "540 unispin, 180 hoptwist", number: 228, letter: 'c', points: 5.8)
  StandardSkillEntry.create(description: "360 unispin, 180 hoptwist, opposite", number: 228, letter: 'd', points: 5.8)
  StandardSkillEntry.create(description: "540 unispin, 180 hoptwist, opposite", number: 228, letter: 'e', points: 6.3)
  StandardSkillEntry.create(description: "180 sidespin", number: 229, letter: 'a', points: 5.4)
  StandardSkillEntry.create(description: "360 sidespin", number: 229, letter: 'b', points: 5.8)
  StandardSkillEntry.create(description: "540 sidespin", number: 229, letter: 'c', points: 6.3)
  StandardSkillEntry.create(description: "idling", number: 251, letter: 'a', points: 1.8)
  StandardSkillEntry.create(description: "idling one foot", number: 251, letter: 'b', points: 2.1)
  StandardSkillEntry.create(description: "idling one foot ext", number: 251, letter: 'c', points: 2.3)
  StandardSkillEntry.create(description: "idling one foot crossed", number: 251, letter: 'd', points: 2.3)
  StandardSkillEntry.create(description: "idling seat in front, seat against body", number: 252, letter: 'a', points: 2.5)
  StandardSkillEntry.create(description: "idling seat in front", number: 252, letter: 'b', points: 2.8)
  StandardSkillEntry.create(description: "idling 1ft seat in front, seat against body", number: 252, letter: 'c', points: 2.9)
  StandardSkillEntry.create(description: "idling 1ft seat in front", number: 252, letter: 'd', points: 3.3)
  StandardSkillEntry.create(description: "idling 1ft seat in front ext, seat against body", number: 252, letter: 'e', points: 3.2)
  StandardSkillEntry.create(description: "idling seat in back, seat against body", number: 252, letter: 'f', points: 3.1)
  StandardSkillEntry.create(description: "idling seat in back", number: 252, letter: 'g', points: 3.4)
  StandardSkillEntry.create(description: "idling seat on side, seat touching body", number: 253, letter: 'a', points: 2.7)
  StandardSkillEntry.create(description: "idling seat on side freehand, touching body", number: 253, letter: 'b', points: 2.9)
  StandardSkillEntry.create(description: "idling seat on side", number: 253, letter: 'c', points: 3.0)
  StandardSkillEntry.create(description: "idling 1ft seat on side, touching body", number: 253, letter: 'd', points: 3.1)
  StandardSkillEntry.create(description: "idling 1ft seat on side", number: 253, letter: 'e', points: 3.5)
  StandardSkillEntry.create(description: "idling 1ft ext seat on side, touching body", number: 253, letter: 'f', points: 3.6)
  StandardSkillEntry.create(description: "idling 1ft ext seat on side", number: 253, letter: 'g', points: 4.2)
  StandardSkillEntry.create(description: "side idle", number: 253, letter: 'h', points: 4.0)
  StandardSkillEntry.create(description: "side idle, 1 hand", number: 253, letter: 'i', points: 4.1)
  StandardSkillEntry.create(description: "crank idle, seat against body", number: 254, letter: 'a', points: 2.9)
  StandardSkillEntry.create(description: "crank idle freehand, seat against body", number: 254, letter: 'b', points: 3.1)
  StandardSkillEntry.create(description: "crank idle", number: 254, letter: 'c', points: 3.2)
  StandardSkillEntry.create(description: "wheel idle", number: 255, letter: 'a', points: 3.7)
  StandardSkillEntry.create(description: "wheel idle, 1ft", number: 255, letter: 'b', points: 3.6)
  StandardSkillEntry.create(description: "wheel idle, 1ft ext", number: 255, letter: 'c', points: 3.8)
  StandardSkillEntry.create(description: "twisting", number: 256, letter: 'a', points: 2.6)
  StandardSkillEntry.create(description: "stillstand", number: 257, letter: 'a', points: 3.6)
  StandardSkillEntry.create(description: "hopping", number: 258, letter: 'a', points: 1.8)
  StandardSkillEntry.create(description: "hopping freehand", number: 258, letter: 'b', points: 2.0)
  StandardSkillEntry.create(description: "hopping seat in front, seat against body", number: 259, letter: 'a', points: 2.5)
  StandardSkillEntry.create(description: "hopping seat in front", number: 259, letter: 'b', points: 2.8)
  StandardSkillEntry.create(description: "hopping seat in back, seat against body", number: 259, letter: 'c', points: 3.1)
  StandardSkillEntry.create(description: "hopping seat in back", number: 259, letter: 'd', points: 3.4)
  StandardSkillEntry.create(description: "hopping on wheel", number: 260, letter: 'a', points: 2.6)
  StandardSkillEntry.create(description: "hopping on wheel, sitting", number: 260, letter: 'b', points: 3.2)
  StandardSkillEntry.create(description: "hopping on wheel, sitting, freehand", number: 260, letter: 'c', points: 3.4)
  StandardSkillEntry.create(description: "stand up hopping on wheel, 1 hand", number: 260, letter: 'd', points: 3.1)
  StandardSkillEntry.create(description: "stand up hopping on wheel, freehanded", number: 260, letter: 'e', points: 3.6)
  StandardSkillEntry.create(description: "hoptwisting", number: 261, letter: 'a', points: 2.6)
  StandardSkillEntry.create(description: "side hopping", number: 262, letter: 'a', points: 2.9)
  StandardSkillEntry.create(description: "side hopping, foot touching tire", number: 262, letter: 'b', points: 2.8)
  StandardSkillEntry.create(description: "mount, 1 hand", number: 301, letter: 'a', points: 1.2)
  StandardSkillEntry.create(description: "mount", number: 301, letter: 'b', points: 1.3)
  StandardSkillEntry.create(description: "mount to idle", number: 301, letter: 'c', points: 1.5)
  StandardSkillEntry.create(description: "mount to 1 ft idle", number: 301, letter: 'd', points: 2.0)
  StandardSkillEntry.create(description: "mount to 1 ft ext idle", number: 301, letter: 'e', points: 2.5)
  StandardSkillEntry.create(description: "rolling mount", number: 302, letter: 'a', points: 1.8)
  StandardSkillEntry.create(description: "rolling mount to 1 ft", number: 302, letter: 'b', points: 2.5)
  StandardSkillEntry.create(description: "rolling mount to 1 ft ext", number: 302, letter: 'c', points: 2.7)
  StandardSkillEntry.create(description: "rolling mount to gliding", number: 302, letter: 'd', points: 3.7)
  StandardSkillEntry.create(description: "rolling mount to coasting", number: 302, letter: 'e', points: 4.5)
  StandardSkillEntry.create(description: "back mount", number: 303, letter: 'a', points: 1.9)
  StandardSkillEntry.create(description: "back mount to idle", number: 303, letter: 'b', points: 2.1)
  StandardSkillEntry.create(description: "back mount to 1 ft idle", number: 303, letter: 'c', points: 2.6)
  StandardSkillEntry.create(description: "back mount to 1 ft ext idle", number: 303, letter: 'd', points: 3.1)
  StandardSkillEntry.create(description: "back mount to ww", number: 303, letter: 'e', points: 2.7)
  StandardSkillEntry.create(description: "back mount to ww 1 ft", number: 303, letter: 'f', points: 3.2)
  StandardSkillEntry.create(description: "back mount to ww 1 ft ext", number: 303, letter: 'g', points: 3.5)
  StandardSkillEntry.create(description: "back mount to stand up ww", number: 303, letter: 'h', points: 4.0)
  StandardSkillEntry.create(description: "mount to stomach on seat, 1 hand on seat", number: 304, letter: 'a', points: 1.5)
  StandardSkillEntry.create(description: "mount to stomach on seat", number: 304, letter: 'b', points: 2.0)
  StandardSkillEntry.create(description: "mount to seat in front, touching body", number: 304, letter: 'c', points: 2.0)
  StandardSkillEntry.create(description: "mount to seat in front", number: 304, letter: 'd', points: 2.4)
  StandardSkillEntry.create(description: "side mount", number: 305, letter: 'a', points: 1.8)
  StandardSkillEntry.create(description: "side mount leg around", number: 305, letter: 'b', points: 3.4)
  StandardSkillEntry.create(description: "side mount leg around twice", number: 305, letter: 'c', points: 4.9)
  StandardSkillEntry.create(description: "side mount from on wheel", number: 305, letter: 'd', points: 2.5)
  StandardSkillEntry.create(description: "side mount from on wheel leg around", number: 305, letter: 'e', points: 4.1)
  StandardSkillEntry.create(description: "side mount reverse", number: 306, letter: 'a', points: 1.8)
  StandardSkillEntry.create(description: "side mount reverse leg around", number: 306, letter: 'b', points: 3.4)
  StandardSkillEntry.create(description: "side mount reverse leg around twice", number: 306, letter: 'c', points: 4.9)
  StandardSkillEntry.create(description: "side mount reverse from on wheel", number: 306, letter: 'd', points: 2.5)
  StandardSkillEntry.create(description: "side mount reverse from on wheel leg around", number: 306, letter: 'e', points: 4.1)
  StandardSkillEntry.create(description: "jump mount", number: 307, letter: 'a', points: 2.2)
  StandardSkillEntry.create(description: "free jump mount", number: 307, letter: 'b', points: 2.7)
  StandardSkillEntry.create(description: "jump mount to seat in front", number: 307, letter: 'c', points: 2.5)
  StandardSkillEntry.create(description: "jump mount to seat in back", number: 307, letter: 'd', points: 2.7)
  StandardSkillEntry.create(description: "jump mount to wheel walk", number: 307, letter: 'e', points: 2.9)
  StandardSkillEntry.create(description: "jump mount from on wheel", number: 307, letter: 'f', points: 2.9)
  StandardSkillEntry.create(description: "180 uni spin jump mount", number: 307, letter: 'g', points: 2.8)
  StandardSkillEntry.create(description: "360 uni spin jump mount", number: 307, letter: 'h', points: 3.0)
  StandardSkillEntry.create(description: "turn around jump mount", number: 307, letter: 'i', points: 3.0)
  StandardSkillEntry.create(description: "jump mount to stand up ww", number: 307, letter: 'j', points: 3.8)
  StandardSkillEntry.create(description: "free jump mount to seat drag in front", number: 307, letter: 'k', points: 4.2)
  StandardSkillEntry.create(description: "jump mount to seat drag in front", number: 307, letter: 'l', points: 4.6)
  StandardSkillEntry.create(description: "jump mount to seat drag in back, holding wheel", number: 307, letter: 'm', points: 4.1)
  StandardSkillEntry.create(description: "jump mount to seat drag in back, feet holding seat", number: 307, letter: 'n', points: 4.8)
  StandardSkillEntry.create(description: "side jump mount", number: 308, letter: 'a', points: 2.5)
  StandardSkillEntry.create(description: "free side jump mount", number: 308, letter: 'b', points: 3.0)
  StandardSkillEntry.create(description: "side jump mount to seat on side", number: 308, letter: 'c', points: 3.1)
  StandardSkillEntry.create(description: "side jump mount to ww", number: 308, letter: 'd', points: 3.8)
  StandardSkillEntry.create(description: "side jump mount to ww 1 ft", number: 308, letter: 'e', points: 3.9)
  StandardSkillEntry.create(description: "side jump mount to ww 1 ft ext", number: 308, letter: 'f', points: 4.1)
  StandardSkillEntry.create(description: "180 uni spin side jump mount", number: 308, letter: 'g', points: 3.8)
  StandardSkillEntry.create(description: "360 uni spin side jump mount", number: 308, letter: 'h', points: 5.2)
  StandardSkillEntry.create(description: "rolling side jump mount to gliding", number: 308, letter: 'i', points: 4.3)
  StandardSkillEntry.create(description: "spin mount 360", number: 309, letter: 'a', points: 2.4)
  StandardSkillEntry.create(description: "spin mount 720", number: 309, letter: 'b', points: 3.4)
  StandardSkillEntry.create(description: "kick up mount, 1 hand on seat", number: 310, letter: 'a', points: 2.8)
  StandardSkillEntry.create(description: "kick up", number: 310, letter: 'b', points: 3.2)
  StandardSkillEntry.create(description: "kick up to wheel walk", number: 310, letter: 'c', points: 3.4)
  StandardSkillEntry.create(description: "kick up mount to ww 1 ft", number: 310, letter: 'd', points: 3.6)
  StandardSkillEntry.create(description: "kick up mount to ww 1 ft ext", number: 310, letter: 'e', points: 3.8)
  StandardSkillEntry.create(description: "pick up", number: 311, letter: 'a', points: 3.2)
  StandardSkillEntry.create(description: "swing up mount", number: 312, letter: 'a', points: 3.2)
  StandardSkillEntry.create(description: "swing up mount, frh", number: 312, letter: 'b', points: 4.0)
  StandardSkillEntry.create(description: "push up mount", number: 313, letter: 'a', points: 3.8)
end

# Update the Standard Skill Routine entries with additional data
if StandardSkillEntry.find_by(number: 1, letter: 'a').friendly_description.blank?
  skill_data = [
    { number: 1, letter: "a", extra_description_number: nil, friendly_description: "Riding (sitting on seat, facing forward).", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 1, letter: "b", extra_description_number: nil, friendly_description: "Riding in a circle (sitting on seat, facing forward).", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 1, letter: "c", extra_description_number: nil, friendly_description: "Riding in a figure eight sitting on seat, facing forward).", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 2, letter: "a", extra_description_number: nil, friendly_description: "Riding while leaning forward and with one hand holding the seatpost under the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 2, letter: "b", extra_description_number: nil, friendly_description: "Riding in a circle while leaning forward and with one hand holding the seatpost under the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 2, letter: "c", extra_description_number: nil, friendly_description: "Riding in a figure 8 while leaning forward and with one hand holding the seatpost under the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 2, letter: "d", extra_description_number: nil, friendly_description: "Riding while leaning forward and with both hands holding the seatpost under the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 2, letter: "e", extra_description_number: nil, friendly_description: "Riding in a circle while leaning forward and with both hands holding the seatpost under the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 2, letter: "f", extra_description_number: nil, friendly_description: "Riding in a figure 8 while leaning forward and with both hands holding the seatpost under the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 3, letter: "a", extra_description_number: nil, friendly_description: "Riding backward.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 3, letter: "b", extra_description_number: nil, friendly_description: "Riding in a circle backward.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 3, letter: "c", extra_description_number: nil, friendly_description: "Riding backward in a figure eight.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 4, letter: "a", extra_description_number: nil, friendly_description: "Riding with seat held in front of the rider. The seat or hand holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 4, letter: "b", extra_description_number: 5, friendly_description: "Riding with seat held in front of the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 4, letter: "c", extra_description_number: 5, friendly_description: "Riding in a circle with seat held in front of the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 4, letter: "d", extra_description_number: 5, friendly_description: "Riding in a figure eight with seat held in front of the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 4, letter: "e", extra_description_number: nil, friendly_description: "Riding with seat held out in front of the rider. Neither hand touches the seat and the seat post is held between the rider's legs. The seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 4, letter: "f", extra_description_number: 25, friendly_description: "Riding with seat held in front of the rider. Neither hand touches the seat and the seat post is held between the rider's legs.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 4, letter: "g", extra_description_number: 25, friendly_description: "Riding in a circle with seat held in front of the rider. Neither hand touches the seat and the seat post is held between the rider's legs.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 4, letter: "h", extra_description_number: 25, friendly_description: "Riding in a figure eight with seat held in front of the rider. Neither hand touches the seat and the seat post is held between the rider's legs.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 5, letter: "a", extra_description_number: nil, friendly_description: "Riding backward with seat held out in front of the rider. The seat or hand holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 5, letter: "b", extra_description_number: 5, friendly_description: "Riding backward with seat held out in front of the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 5, letter: "c", extra_description_number: 5, friendly_description: "Riding backward in a circle with seat held out in front of the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 5, letter: "d", extra_description_number: 5, friendly_description: "Riding backward in a figure eight with seat held out in front of the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 5, letter: "e", extra_description_number: nil, friendly_description: "Riding backward with seat held out in front of the rider. Neither hand touches the seat and the seat post is held between the rider's legs. The seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 5, letter: "f", extra_description_number: 25, friendly_description: "Riding backward with seat held out in front of the rider. Neither hand touches the seat and the seat post is held between the rider's legs.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 5, letter: "g", extra_description_number: 25, friendly_description: "Riding backward in a circle with seat held out in front of the rider. Neither hand touches the seat and the seat post is held between the rider's legs.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 6, letter: "a", extra_description_number: nil, friendly_description: "Riding with the seat held out behind the rider. The seat or the hand holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 6, letter: "b", extra_description_number: 5, friendly_description: "Riding with the seat held out behind the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 6, letter: "c", extra_description_number: 5, friendly_description: "Riding in a circle with the seat held out behind the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 6, letter: "d", extra_description_number: 5, friendly_description: "Riding in a figure eight with the seat held out behind the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 7, letter: "a", extra_description_number: nil, friendly_description: "Riding backward with the seat held out behind the rider. The seat or the hand holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 7, letter: "b", extra_description_number: 5, friendly_description: "Riding backward with the seat held out behind the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 7, letter: "c", extra_description_number: 5, friendly_description: "Riding backward in a circle with the seat held out behind the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 7, letter: "d", extra_description_number: 5, friendly_description: "Riding backward in a figure eight with the seat held out behind the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 8, letter: "a", extra_description_number: nil, friendly_description: "Riding with the seat held out to the side of the rider. The seat or the hand holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 8, letter: "b", extra_description_number: nil, friendly_description: "Riding in a circle with the seat held out to the side of the rider. The seat or the hand holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 8, letter: "c", extra_description_number: 5, friendly_description: "Riding with the seat held out to the side of the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 8, letter: "d", extra_description_number: 5, friendly_description: "Riding in a circle with the seat held out to the side of the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 9, letter: "a", extra_description_number: nil, friendly_description: "Riding backward with the seat held out to the side of the rider.  The seat or the hand holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 9, letter: "b", extra_description_number: 5, friendly_description: "Riding backward with the seat held out to the side of the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 9, letter: "c", extra_description_number: 5, friendly_description: "Riding backward in a circle with the seat held out to the side of the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 10, letter: "a", extra_description_number: nil, friendly_description: "Riding with the abdomen on the seat. One hand holds onto the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 10, letter: "b", extra_description_number: 7, friendly_description: "Riding with the abdomen on the seat, frh.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 10, letter: "c", extra_description_number: 7, friendly_description: "Riding in a circle with the abdomen on the seat, frh.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 10, letter: "d", extra_description_number: 7, friendly_description: "Riding in a figure eight with the abdomen on the seat, frh.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 11, letter: "a", extra_description_number: 7, friendly_description: "Riding backward with the abdomen on the seat, hands free.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 11, letter: "b", extra_description_number: 7, friendly_description: "Riding backward in a circle with the abdomen on the seat, hands free.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 11, letter: "c", extra_description_number: 7, friendly_description: "Riding backward in a figure eight with the abdomen on the seat, hands free.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 12, letter: "a", extra_description_number: nil, friendly_description: "Riding with no part of the body other than the chin touching the back of the seat, freehanded. One hand may touch the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 12, letter: "b", extra_description_number: 7, friendly_description: "Riding with no part of the body other than the chin touching the back of the seat, freehanded.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 12, letter: "c", extra_description_number: 7, friendly_description: "Riding in a circle with no part of the body other than the chin touching the back of the seat, freehanded.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 12, letter: "d", extra_description_number: 7, friendly_description: "Riding in a figure eight with no part of the body other than the chin touching the back of the seat, freehanded.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 13, letter: "a", extra_description_number: nil, friendly_description: "Riding backward with no part of the body other than the chin touching the back of the seat, freehanded. One hand may touch the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 13, letter: "b", extra_description_number: 7, friendly_description: "Riding backward with no part of the body other than the chin touching the back of the seat, freehanded.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 13, letter: "c", extra_description_number: 7, friendly_description: "Riding backward in a circle with no part of the body other than the chin touching the back of the seat, freehanded.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 13, letter: "d", extra_description_number: 7, friendly_description: "Riding backward in a figure eight with no part of the body other than the chin touching the back of the seat, freehanded.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 14, letter: "a", extra_description_number: nil, friendly_description: "Riding with the seat dragging on the floor, in front of the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 14, letter: "b", extra_description_number: nil, friendly_description: "Riding in a circle with the seat dragging on the floor, in front of the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 14, letter: "c", extra_description_number: nil, friendly_description: "Riding in a figure eight with the seat dragging on the floor, in front of the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 15, letter: "a", extra_description_number: nil, friendly_description: "Riding backwards with the seat dragging on the floor, in front of the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 15, letter: "b", extra_description_number: nil, friendly_description: "Riding backwards in a circle with the seat dragging on the floor, in front of the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 15, letter: "c", extra_description_number: nil, friendly_description: "Riding backwards in a figure eight with the seat dragging on the floor, in front of the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 16, letter: "a", extra_description_number: nil, friendly_description: "Riding with the seat dragging on the floor, behind the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 16, letter: "b", extra_description_number: nil, friendly_description: "Riding in a circle with the seat dragging on the floor, behind the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 16, letter: "c", extra_description_number: nil, friendly_description: "Riding in a figure eight with the seat dragging on the floor, behind the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 17, letter: "a", extra_description_number: nil, friendly_description: "Riding backward with the seat dragging on the floor, behind the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 17, letter: "b", extra_description_number: nil, friendly_description: "Riding backward in a circle with the seat dragging on the floor, behind the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 17, letter: "c", extra_description_number: nil, friendly_description: "Riding backward in a figure 8 with the seat dragging on the floor, behind the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 18, letter: "a", extra_description_number: nil, friendly_description: "Riding with the feet parallel to the wheel axle and the body turned 90 degrees to the riding direction with the seat in front holding with one or two hands. The seat or the hands holding the seat may touch the body.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 18, letter: "b", extra_description_number: 5, friendly_description: "Riding with the feet parallel to the wheel axle and the body turned 90 degrees to the riding direction with the seat in front holding with one or two hands.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 18, letter: "c", extra_description_number: nil, friendly_description: "Riding with one foot parallel to the wheel axle and the body turned 90 degrees to the riding direction with the seat in front holding with one or two hands. The seat or the hands holding the seat may touch the body. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 18, letter: "d", extra_description_number: nil, friendly_description: "Riding seat drag in front (forward of the direction of travel) with the feet parallel to the wheel axle and the body turned 90 degrees to the riding direction.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 19, letter: "a", extra_description_number: nil, friendly_description: "Riding with one foot on pedal.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 19, letter: "b", extra_description_number: nil, friendly_description: "Riding in a circle with one foot on pedal.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 19, letter: "c", extra_description_number: nil, friendly_description: "Riding in a figure eight with one foot on pedal.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 19, letter: "d", extra_description_number: nil, friendly_description: "Riding with one foot on pedal. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 19, letter: "e", extra_description_number: nil, friendly_description: "Riding in a circle with one foot on pedal. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 19, letter: "f", extra_description_number: nil, friendly_description: "Riding in a figure eight with one foot on pedal. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 19, letter: "g", extra_description_number: 33, friendly_description: "Riding with one foot on pedal. The free leg is crossed over the pedaling leg.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 19, letter: "h", extra_description_number: 33, friendly_description: "Riding in a circle with one foot on pedal. The free leg is crossed over the pedaling leg.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 19, letter: "i", extra_description_number: 33, friendly_description: "Riding in a figure eight with one foot on pedal. The free leg is crossed over the pedaling leg.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 20, letter: "a", extra_description_number: nil, friendly_description: "Riding backward with one foot on pedal.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 20, letter: "b", extra_description_number: nil, friendly_description: "Riding backward in a circle with one foot on pedal.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 20, letter: "c", extra_description_number: nil, friendly_description: "Riding backward in a figure eight with one foot on pedal.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 20, letter: "d", extra_description_number: nil, friendly_description: "Riding backward with one foot on pedal. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 20, letter: "e", extra_description_number: nil, friendly_description: "Riding backward in a circle with one foot on pedal. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 20, letter: "f", extra_description_number: nil, friendly_description: "Riding backward in a figure eight with one foot on pedal. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 21, letter: "a", extra_description_number: nil, friendly_description: "Riding with the seat held out in front of the rider with ONE hand, one foot on pedal. The seat or hand holding the seat my rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 21, letter: "b", extra_description_number: 5, friendly_description: "Riding with the seat held out in front of the rider with ONE hand, one foot on pedal.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 21, letter: "c", extra_description_number: 5, friendly_description: "Riding in a circle with the seat held out in front of the rider with ONE hand, one foot on pedal.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 21, letter: "d", extra_description_number: 5, friendly_description: "Riding in a figure eight with the seat held out in front of the rider with ONE hand, one foot on pedal.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 21, letter: "e", extra_description_number: nil, friendly_description: "Riding with the seat held out in front of the rider, one foot on pedal. The seat or hand holding the seat my rest against the rider. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 21, letter: "f", extra_description_number: nil, friendly_description: "Riding in a circle with the seat held out in front of the rider, one foot on pedal. The seat or hand holding the seat my rest against the rider. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 22, letter: "a", extra_description_number: nil, friendly_description: "Riding backward with the seat held out in front of the rider, one foot on pedal. The seat or hand holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 22, letter: "b", extra_description_number: 5, friendly_description: "Riding backward with the seat held out in front of the rider, one foot on pedal.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 22, letter: "c", extra_description_number: 5, friendly_description: "Riding backward in a circle with the seat held out in front of the rider, one foot on pedal.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 22, letter: "d", extra_description_number: nil, friendly_description: "Riding backward with the seat held out in front of the rider, one foot on pedal. The seat or hand holding the seat my rest against the rider. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 22, letter: "e", extra_description_number: nil, friendly_description: "Riding backward in a circle with the seat held out in front of the rider, one foot on pedal. The seat or hand holding the seat my rest against the rider. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 23, letter: "a", extra_description_number: nil, friendly_description: "Riding with the seat held out to the side of the rider, one foot on pedal. The seat or the hand holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 23, letter: "b", extra_description_number: 5, friendly_description: "Riding with the seat held out to the side of the rider, one foot on pedal.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 23, letter: "c", extra_description_number: 5, friendly_description: "Riding in a circle with the seat held out to the side of the rider, one foot on pedal.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 23, letter: "d", extra_description_number: 5, friendly_description: "Riding in a figure eight with the seat held out to the side of the rider, one foot on pedal.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 24, letter: "a", extra_description_number: nil, friendly_description: "Riding backward with the seat held out to the side of the rider, one foot on pedal. The seat or the hand holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 24, letter: "b", extra_description_number: 5, friendly_description: "Riding backward with the seat held out to the side of the rider, one foot on pedal.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 24, letter: "c", extra_description_number: 5, friendly_description: "Riding backward in a circle with the seat held out to the side of the rider, one foot on pedal.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 25, letter: "a", extra_description_number: nil, friendly_description: "Riding 1ft while sitting partially on seat with the free leg resting on the seat or on the same side as the pedaling foot. One hand may touch the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 25, letter: "b", extra_description_number: nil, friendly_description: "Riding 1 foot in a circle while sitting partially on seat with the free leg resting on the seat or on the same side as the pedaling foot. One hand may touch the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 25, letter: "c", extra_description_number: 7, friendly_description: "Riding 1ft while sitting partially on seat with the free leg resting on the seat or on the same side as the pedaling foot.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 25, letter: "d", extra_description_number: 7, friendly_description: "Riding 1 foot in a circle while sitting partially on seat with the free leg resting on the seat or on the same side as the pedaling foot.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 25, letter: "e", extra_description_number: 7, friendly_description: "Riding 1 foot in a figure eight while sitting partially on seat with the free leg resting on the seat or on the same side as the pedaling foot.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 26, letter: "a", extra_description_number: 29, friendly_description: "Riding one footed, with the pedaling foot on the non-corresponding pedal. Non pedaling foot can be extended, or on the fork.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 26, letter: "b", extra_description_number: 29, friendly_description: "Riding one footed in a circle, with the pedaling foot on the non-corresponding pedal. Non pedaling foot can be extended, or on the fork.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 26, letter: "c", extra_description_number: 29, friendly_description: "Riding one footed in a figure eight, with the pedaling foot on the non-corresponding pedal. Non pedaling foot can be extended, or on the fork.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 27, letter: "a", extra_description_number: 29, friendly_description: "Riding backward one footed, with the pedaling foot on the non-corresponding pedal. Non pedaling foot can be extended, or on the fork. ", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 27, letter: "b", extra_description_number: 29, friendly_description: "Riding backward one footed in a circle, with the pedaling foot on the non-corresponding pedal. Non pedaling foot can be extended, or on the fork. ", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 27, letter: "c", extra_description_number: 29, friendly_description: "Riding backward one footed in a figure 8, with the pedaling foot on the non-corresponding pedal. Non pedaling foot can be extended, or on the fork. ", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 28, letter: "a", extra_description_number: 29, friendly_description: "Riding 1ft, next to the unicycle, with foot on the non-corresponding pedal, holding on to the seat with both hands. The seat or the hands holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 28, letter: "b", extra_description_number: 29, friendly_description: "Riding 1 foot in a circle, next to the unicycle, with foot on the non-corresponding pedal, holding on to the seat with both hands. The seat or the hands holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 28, letter: "c", extra_description_number: 29, friendly_description: "Riding 1ft in a figure eight, next to the unicycle, with foot on the non-corresponding pedal, holding on to the seat with both hands. The seat or the hands holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 28, letter: "d", extra_description_number: 29, friendly_description: "Riding 1ft, next to the unicycle, with foot on the non-corresponding pedal, holding on to the seat with one hand. The seat or the hand holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 28, letter: "e", extra_description_number: 29, friendly_description: "Riding 1ft in a circle, next to the unicycle, with foot on the non-corresponding pedal, holding on to the seat with one hand. The seat or the hand holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 28, letter: "f", extra_description_number: 29, friendly_description: "Riding 1ft in a figure eight, next to the unicycle, with foot on the non-corresponding pedal, holding on to the seat with one hand. The seat or the hand holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 29, letter: "a", extra_description_number: 29, friendly_description: "Riding 1ft bwd, next to the unicycle, with foot on the non-corresponding pedal, holding on to the seat with both hands. The seat or the hands holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 29, letter: "b", extra_description_number: 29, friendly_description: "Riding 1ft bwd in a circle, next to the unicycle, with foot on the non-corresponding pedal, holding on to the seat with both hands. The seat or the hands holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 29, letter: "c", extra_description_number: 29, friendly_description: "Riding 1ft bwd in a figure 8, next to the unicycle, with foot on the non-corresponding pedal, holding on to the seat with both hands. The seat or the hands holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 29, letter: "d", extra_description_number: 29, friendly_description: "Riding 1ft bwd, next to the unicycle, with foot on the non-corresponding pedal, holding on to the seat with one hand. The seat or the hand holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 29, letter: "e", extra_description_number: 29, friendly_description: "Riding 1ft bwd in a circle, next to the unicycle, with foot on the non-corresponding pedal, holding on to the seat with one hand. The seat or the hand holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 29, letter: "f", extra_description_number: 29, friendly_description: "Riding 1ft bwd in a figure 8, next to the unicycle, with foot on the non-corresponding pedal, holding on to the seat with one hand. The seat or the hand holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 30, letter: "a", extra_description_number: nil, friendly_description: "Propelling the wheel with the feet placed on the wheel in front of the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 30, letter: "b", extra_description_number: nil, friendly_description: "Propelling the wheel in a circle with the feet placed on the wheel in front of the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 30, letter: "c", extra_description_number: nil, friendly_description: "Propelling the wheel in a figure eight with the feet placed on the wheel in front of the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 31, letter: "a", extra_description_number: nil, friendly_description: "Riding backward by propelling the wheel with the feet placed on the wheel in front of the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 31, letter: "b", extra_description_number: nil, friendly_description: "Riding backward in a circle by propelling the wheel with the feet placed on the wheel in front of the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 32, letter: "a", extra_description_number: nil, friendly_description: "Riding forward by propelling the wheel with one foot placed on the wheel in front of the frame and the other foot placed on the wheel behind the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 32, letter: "b", extra_description_number: nil, friendly_description: "Riding forward in a circle by propelling the wheel with one foot placed on the wheel in front of the frame and the other foot placed on the wheel behind the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 33, letter: "a", extra_description_number: nil, friendly_description: "Riding backward by propelling the wheel with one foot placed on the wheel in front of the frame and the other foot placed on the wheel behind the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 33, letter: "b", extra_description_number: nil, friendly_description: "Riding backward in a circle by propelling the wheel with one foot placed on the wheel in front of the frame and the other foot placed on the wheel behind the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 34, letter: "a", extra_description_number: nil, friendly_description: "Riding backward by propelling the wheel with the feet placed on the wheel behind the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 34, letter: "b", extra_description_number: nil, friendly_description: "Riding backward in a circle by propelling the wheel with the feet placed on the wheel behind the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 35, letter: "a", extra_description_number: nil, friendly_description: "Riding backward by propelling the wheel with the feet placed on both sides of the wheel, behind the frame. Feet may contact spokes, rim, or tire.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 35, letter: "b", extra_description_number: nil, friendly_description: "Riding backward in a circle by propelling the wheel with the feet placed on both sides of the wheel, behind the frame. Feet may contact spokes, rim, or tire.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 36, letter: "a", extra_description_number: nil, friendly_description: "Walking the wheel using only one foot on the wheel, in front of the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 36, letter: "b", extra_description_number: nil, friendly_description: "Walking the wheel in a circle using only one foot on the wheel, in front of the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 36, letter: "c", extra_description_number: nil, friendly_description: "Walking the wheel in a figure eight using only one foot on the wheel, in front of the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 36, letter: "d", extra_description_number: nil, friendly_description: "Walking the wheel using only one foot on the wheel, in front of the frame. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 36, letter: "e", extra_description_number: nil, friendly_description: "Walking the wheel in a circle using only one foot on the wheel, in front of the frame. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 36, letter: "f", extra_description_number: nil, friendly_description: "Walking the wheel in a figure eight using only one foot on the wheel, in front of the frame. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 36, letter: "g", extra_description_number: 33, friendly_description: "Walking the wheel using only one foot on the wheel, in front of the frame. The free leg is crossed over the leg and above the knee that is walking the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 36, letter: "h", extra_description_number: 33, friendly_description: "Walking the wheel in a circle using only one foot on the wheel, in front of the frame. The free leg is crossed over the leg and above the knee that is walking the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 37, letter: "a", extra_description_number: nil, friendly_description: "Walking the wheel backwards with one foot on the wheel, in front of the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 37, letter: "b", extra_description_number: nil, friendly_description: "Walking the wheel backwards in a circle with one foot on the wheel, in front of the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 37, letter: "c", extra_description_number: nil, friendly_description: "Walking the wheel backwards with one foot on the wheel, in front of the frame. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 37, letter: "d", extra_description_number: nil, friendly_description: "Walking the wheel backwards in a circle with one foot on the wheel, in front of the frame. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 38, letter: "a", extra_description_number: nil, friendly_description: "Walking the wheel backward with one foot on the wheel behind the frame. The other foot rests on the frame with the toe being used as a brake to maintain balance.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 38, letter: "b", extra_description_number: nil, friendly_description: "Walking the wheel backward in a circle with one foot on the wheel behind the frame. The other foot rests on the frame with the toe being used as a brake to maintain balance.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 38, letter: "c", extra_description_number: nil, friendly_description: "Walking the wheel backward with one foot on the wheel behind the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 38, letter: "d", extra_description_number: nil, friendly_description: "Walking the wheel backward in a circle with one foot on the wheel behind the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 39, letter: "a", extra_description_number: nil, friendly_description: "Riding by propelling the unicycle with the hands on the wheel and with the feet resting on the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 39, letter: "b", extra_description_number: nil, friendly_description: "Riding in a circle by propelling the unicycle with the hands on the wheel and with the feet resting on the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 39, letter: "c", extra_description_number: nil, friendly_description: "Riding by propelling the unicycle with the hands on the wheel and with the feet resting on the frame. The legs are extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 39, letter: "d", extra_description_number: nil, friendly_description: "Riding in a circle by propelling the unicycle with the hands on the wheel and with the feet resting on the frame. The legs are extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 40, letter: "a", extra_description_number: nil, friendly_description: "Hand wheel walk with one hand on the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 40, letter: "b", extra_description_number: nil, friendly_description: "Hand wheel walk in a circle with one hand on the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 40, letter: "c", extra_description_number: nil, friendly_description: "Hand wheel walk with one hand on the wheel. The legs are extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 40, letter: "d", extra_description_number: nil, friendly_description: "Hand wheel walk in a circle with one hand on the wheel. The legs are extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 41, letter: "a", extra_description_number: nil, friendly_description: "Hand wheel walk with the abdomen on the seat and the legs extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 41, letter: "b", extra_description_number: nil, friendly_description: "Hand wheel walk in a circle with the abdomen on the seat and the legs extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 42, letter: "a", extra_description_number: nil, friendly_description: "One hand wheel walk with the abdomen on the seat and the legs extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 42, letter: "b", extra_description_number: nil, friendly_description: "One hand wheel walk in a circle with the abdomen on the seat and the legs extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 43, letter: "a", extra_description_number: nil, friendly_description: "Riding forward with the seat touching the body and held in front with one or two hands, the rider propels the unicycle by pushing the wheel in front of the frame with the feet.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 43, letter: "b", extra_description_number: nil, friendly_description: "Riding forward in a circle with the seat touching the body and held in front with one or two hands, the rider propels the unicycle by pushing the wheel in front of the frame with the feet.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 43, letter: "c", extra_description_number: nil, friendly_description: "Riding forward with the seat touching the body and held in front with one or two hands, the rider propels the unicycle by pushing the wheel in front of the frame with one foot with the leg of the standing foot behind the middle of the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 43, letter: "d", extra_description_number: nil, friendly_description: "Riding forward with the seat touching the body and held in front with one or two hands, the rider propels the unicycle by pushing the wheel in front of the frame with one foot. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 44, letter: "a", extra_description_number: nil, friendly_description: "Riding backward with the seat held out in front with one or two hands, the rider propels the unicycle by pushing the wheel behind the frame with the feet. The seat or hand(s) holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 44, letter: "b", extra_description_number: nil, friendly_description: "Riding backward in a circle with the seat held out in front with one or two hands, the rider propels the unicycle by pushing the wheel behind the frame with the feet. The seat or hand(s) holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 44, letter: "c", extra_description_number: nil, friendly_description: "Riding backward with the seat held out in front with one or two hands, the rider propels the unicycle by pushing the wheel behind the frame with one foot. The seat or hand(s) holding the seat may rest against the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 44, letter: "d", extra_description_number: nil, friendly_description: "Riding backward with the seat held out in front with one or two hands, the rider propels the unicycle by pushing the wheel behind the frame with one foot. The seat or hand(s) holding the seat may rest against the rider. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 45, letter: "a", extra_description_number: nil, friendly_description: "Riding forward with the seat touching the body and held in back with one or two hands, the rider propels the unicycle by pushing the wheel in front the frame with the feet.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 45, letter: "b", extra_description_number: nil, friendly_description: "Riding forward in a circle with the seat touching the body and held in back with one or two hands, the rider propels the unicycle by pushing the wheel in front the frame with the feet.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 45, letter: "c", extra_description_number: nil, friendly_description: "Riding forward with the seat touching the body and held in back with one or two hands, the rider propels the unicycle by pushing the wheel in front the frame with the feet. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 46, letter: "a", extra_description_number: nil, friendly_description: "Riding by walking the wheel with the feet on the wheel in front of the frame and on the same side of the seat. The rider is sitting partially on the seat. One hand may touch the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 46, letter: "b", extra_description_number: 7, friendly_description: "Riding by walking the wheel with the feet on the wheel in front of the frame and on the same side of the seat. The rider is sitting partially on the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 46, letter: "c", extra_description_number: 7, friendly_description: "Riding in a circle by walking the wheel with the feet on the wheel in front of the frame and on the same side of the seat. The rider is sitting partially on the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 46, letter: "d", extra_description_number: nil, friendly_description: "Riding by walking the wheel with one foot on the wheel in front of the frame and on the same side of the seat. The rider is sitting partially on the seat. One hand may touch the seat; the free leg is touching the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 46, letter: "e", extra_description_number: 7, friendly_description: "Riding by walking the wheel with one foot on the wheel in front of the frame and on the same side of the seat. The rider is sitting partially on the seat. The free leg is touching the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 46, letter: "f", extra_description_number: 7, friendly_description: "Riding in a circle by walking the wheel with one foot on the wheel in front of the frame and on the same side of the seat. The rider is sitting partially on the seat. The free leg is touching the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 46, letter: "g", extra_description_number: nil, friendly_description: "Standing on the frame with the seat held out to the side with one hand, walking the wheel with one foot on the wheel in front of the frame and on the same side of the seat. The seat and/or frame may touch the body of the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 46, letter: "h", extra_description_number: 7, friendly_description: "Standing on the frame with the seat on the side, walking the wheel with one foot on the wheel in front of the frame and on the same side of the seat. The seat and/or frame may touch the body of the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 46, letter: "i", extra_description_number: 7, friendly_description: "Standing on the frame with the seat on the side, walking the wheel in a circle with one foot on the wheel in front of the frame and on the same side of the seat. The seat and/or frame may touch the body of the rider.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 47, letter: "a", extra_description_number: nil, friendly_description: "Riding backward by walking the wheel with one foot on the wheel behind the frame and the other foot rests on the frame with the toe being used as a brake to maintain balance. Both legs are on one side of the seat and one hand is holding the seat. The seat touches the legs. The rider is sitting partially on the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 47, letter: "b", extra_description_number: nil, friendly_description: "Riding backward in a circle by walking the wheel with one foot on the wheel behind the frame and the other foot rests on the frame with the toe being used as a brake to maintain balance. Both legs are on one side of the seat and one hand is holding the seat. The seat touches the legs. The rider is sitting partially on the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 47, letter: "c", extra_description_number: nil, friendly_description: "Standing on the frame and walking the wheel backward with one foot on the wheel behind the frame and the other foot rests on the frame with the toe being used as a brake to maintain balance. Both legs are on one side of the seat and one hand is holding the seat. The seat touches the legs.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 47, letter: "d", extra_description_number: nil, friendly_description: "Standing on the frame and walking the wheel backward in a circle with one foot on the wheel behind the frame and the other foot rests on the frame with the toe being used as a brake to maintain balance. Both legs are on one side of the seat and one hand is holding the seat. The seat touches the legs.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 48, letter: "a", extra_description_number: nil, friendly_description: "Riding sideways, standing on the wheel with one foot in front of the frame and the other behind the frame, holding on to the seat with both hands.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 48, letter: "b", extra_description_number: nil, friendly_description: "Riding sideways in a circle, standing on the wheel with one foot in front of the frame and the other behind the frame, holding on to the seat with both hands.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 49, letter: "a", extra_description_number: nil, friendly_description: "Riding sideways, standing on the wheel with one foot in front of the frame and the free leg extended, holding on to the seat with both hands.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 49, letter: "b", extra_description_number: nil, friendly_description: "Riding sideways in a circle, standing on the wheel with one foot in front of the frame and the free leg extended, holding on to the seat with both hands.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 49, letter: "c", extra_description_number: nil, friendly_description: "Riding sideways, standing on the wheel with one foot in front of the frame and the free leg extended, holding on to the seat with both hands. The free leg is placed on the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 50, letter: "a", extra_description_number: nil, friendly_description: "Walking the wheel sideways with one foot in front of the frame and the other behind the frame, sitting sideways on the seat with one hand holding the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 50, letter: "b", extra_description_number: 7, friendly_description: "Walking the wheel sideways with one foot in front of the frame and the other behind the frame, sitting sideways on the seat with no hands touching the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 50, letter: "c", extra_description_number: 7, friendly_description: "Walking the wheel sideways in a circle with one foot in front of the frame and the other behind the frame, sitting sideways on the seat with no hands touching the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 50, letter: "d", extra_description_number: 7, friendly_description: "Walking the wheel sideways with one foot in front of the frame and the other on the frame, sitting sideways on the seat with no hands touching the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 50, letter: "e", extra_description_number: 7, friendly_description: "Walking the wheel sideways with one foot in front of the frame and the other leg extended, sitting sideways on the seat with no hands touching the seat.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 51, letter: "a", extra_description_number: nil, friendly_description: "Standing on the frame walking the wheel using only one foot on the wheel, in front of the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 51, letter: "b", extra_description_number: nil, friendly_description: "Standing on the frame walking the wheel in a circle using only one foot on the wheel, in front of the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 52, letter: "a", extra_description_number: nil, friendly_description: "Standing on the frame, walking the wheel backward with one foot on the wheel behind the frame, the other foot rests on the frame with the toe being used as a brake to maintain balance.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 52, letter: "b", extra_description_number: nil, friendly_description: "Standing on the frame, walking the wheel backward in a circle with one foot on the wheel behind the frame, the other foot rests on the frame with the toe being used as a brake to maintain balance.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 52, letter: "c", extra_description_number: nil, friendly_description: "Standing on the frame, walking the wheel backward with one foot on the wheel in front of the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 52, letter: "d", extra_description_number: nil, friendly_description: "Standing on the frame, walking the wheel backward in a circle with one foot on the wheel in front of the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 53, letter: "a", extra_description_number: nil, friendly_description: "Riding with one foot on the wheel and the other foot resting on the frame, maintaining balance only by the braking action of the foot on the wheel. The braking foot is not touching the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 53, letter: "b", extra_description_number: nil, friendly_description: "Riding with one foot in a circle on the wheel and the other foot resting on the frame, maintaining balance only by the braking action of the foot on the wheel. The braking foot is not touching the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 53, letter: "c", extra_description_number: nil, friendly_description: "Riding by maintaining balance only by the braking action of one or both feet on the wheel. The heel(s) of the braking foot (or feet) is on the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 53, letter: "d", extra_description_number: nil, friendly_description: "Riding in a circle by maintaining balance only by the braking action of one or both feet on the wheel. The heel(s) of the braking foot (or feet) is on the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 53, letter: "e", extra_description_number: nil, friendly_description: "Riding with one foot on the wheel and the other foot resting on the frame, maintaining balance only by the braking action of the foot on the wheel. The braking foot is not touching the frame. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 53, letter: "f", extra_description_number: nil, friendly_description: "Riding in a circle with one foot on the wheel and the other foot resting on the frame, maintaining balance only by the braking action of the foot on the wheel. The braking foot is not touching the frame. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 54, letter: "a", extra_description_number: nil, friendly_description: "Riding backward with one foot on the wheel behind the frame and the other foot resting on the frame, maintaining balance only by the braking action of the foot on the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 54, letter: "b", extra_description_number: nil, friendly_description: "Riding backward in a circle with one foot on the wheel behind the frame and the other foot resting on the frame, maintaining balance only by the braking action of the foot on the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 54, letter: "c", extra_description_number: nil, friendly_description: "Riding backward with both feet on the frame, maintaining balance only by the braking action of one toe on the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 54, letter: "d", extra_description_number: nil, friendly_description: "Riding backward in a circle with both feet on the frame, maintaining balance only by the braking action of one toe on the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 54, letter: "e", extra_description_number: nil, friendly_description: "Riding backward maintaining balance only by the braking action of one toe on the wheel. The heel of the braking foot is on the frame with the free leg extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 54, letter: "f", extra_description_number: nil, friendly_description: "Riding backward in a circle maintaining balance only by the braking action of one toe on the wheel. The heel of the braking foot is on the frame with the free leg extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 55, letter: "a", extra_description_number: 29, friendly_description: "Riding with one foot resting on the frame and the free foot extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 55, letter: "b", extra_description_number: 29, friendly_description: "Riding in a circle with one foot resting on the frame and the free foot extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 55, letter: "c", extra_description_number: 29, friendly_description: "Riding in a figure eight with one foot resting on the frame and the free foot extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 55, letter: "d", extra_description_number: nil, friendly_description: "Riding with both feet resting on the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 55, letter: "e", extra_description_number: nil, friendly_description: "Riding in a circle with both feet resting on the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 55, letter: "f", extra_description_number: nil, friendly_description: "Riding in a figure eight with both feet resting on the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 56, letter: "a", extra_description_number: 29, friendly_description: "Riding backward with one foot resting on the frame and the free foot extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 56, letter: "b", extra_description_number: 29, friendly_description: "Riding backward in a circle with one foot resting on the frame and the free foot extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 56, letter: "c", extra_description_number: 29, friendly_description: "Riding backward in a figure eight with one foot resting on the frame and the free foot extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 56, letter: "d", extra_description_number: nil, friendly_description: "Riding backward with both feet resting on the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 56, letter: "e", extra_description_number: nil, friendly_description: "Riding backward in a circle with both feet resting on the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 56, letter: "f", extra_description_number: nil, friendly_description: "Riding backward in a figure eight with both feet resting on the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 57, letter: "a", extra_description_number: nil, friendly_description: "Gliding while standing on the frame with one foot on the wheel, in front of the frame, maintaining balance only by the braking action of the foot on the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 57, letter: "b", extra_description_number: nil, friendly_description: "Gliding while standing on the frame with one foot on the wheel in a circle, in front of the frame, maintaining balance only by the braking action of the foot on the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 57, letter: "c", extra_description_number: nil, friendly_description: "Gliding while standing on the frame with one or both feet on the wheel, in front of the frame, maintaining balance only by the braking action of the foot or feet on the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 57, letter: "d", extra_description_number: nil, friendly_description: "Gliding in a circle while standing on the frame with one or both feet on the wheel, in front of the frame, maintaining balance only by the braking action of the foot or feet on the wheel.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 57, letter: "e", extra_description_number: nil, friendly_description: "Gliding while standing on the frame with one foot on the wheel, in front of the frame, maintaining balance only by the braking action of the foot on the wheel. One hand is on the saddle and the free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 57, letter: "f", extra_description_number: 7, friendly_description: "Gliding while standing on the frame with one foot on the wheel, in front of the frame, maintaining balance only by the braking action of the foot on the wheel. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 57, letter: "g", extra_description_number: 7, friendly_description: "Gliding in a circle while standing on the frame with one foot on the wheel, in front of the frame, maintaining balance only by the braking action of the foot on the wheel. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 58, letter: "a", extra_description_number: nil, friendly_description: "Gliding backward while standing on the frame, maintaining balance only by the braking action of the foot on the wheel. The braking foot is not touching the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 58, letter: "b", extra_description_number: nil, friendly_description: "Gliding backward in a circle while standing on the frame, maintaining balance only by the braking action of the foot on the wheel. The braking foot is not touching the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 58, letter: "c", extra_description_number: nil, friendly_description: "Gliding backward while standing on the frame, maintaining balance only by the braking action of the foot on the wheel. One or both feet are braking and the heel(s) of the braking foot (or feet) is on the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 58, letter: "d", extra_description_number: nil, friendly_description: "Gliding backward in a circle while standing on the frame, maintaining balance only by the braking action of the foot on the wheel. One or both feet are braking and the heel(s) of the braking foot (or feet) is on the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 58, letter: "e", extra_description_number: nil, friendly_description: "Gliding backward while standing on the frame, maintaining balance only by the braking action of the foot on the wheel. The heel of the braking foot is on the frame. The free leg is extended. One hand on the saddle.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 58, letter: "f", extra_description_number: 7, friendly_description: "Gliding backward while standing on the frame, maintaining balance only by the braking action of the foot on the wheel. The heel of the braking foot is on the frame. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 58, letter: "g", extra_description_number: 7, friendly_description: "Gliding backward in a circle while standing on the frame, maintaining balance only by the braking action of the foot on the wheel. The heel of the braking foot is on the frame. The free leg is extended.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 59, letter: "a", extra_description_number: nil, friendly_description: "Coasting while standing upright with both feet on the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 59, letter: "b", extra_description_number: nil, friendly_description: "Coasting in a circle while standing upright with both feet on the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 59, letter: "c", extra_description_number: nil, friendly_description: "Coasting in a figure eight while standing upright with both feet on the frame.", skill_speed: 1, skill_before: nil, skill_after: nil},
    { number: 101, letter: "a", extra_description_number: 19, friendly_description: "From riding, pulling out the seat to seat in front.", skill_speed: 3, skill_before: 101, skill_after: 106},
    { number: 101, letter: "b", extra_description_number: 40, friendly_description: "From riding, pulling out the seat to stomach on seat", skill_speed: 3, skill_before: 101, skill_after: 136},
    { number: 102, letter: "a", extra_description_number: 17, friendly_description: "From seat in front, getting back on the seat into riding.", skill_speed: 3, skill_before: 106, skill_after: 101},
    { number: 102, letter: "b", extra_description_number: 17, friendly_description: "From stomach on seat, getting back on the seat into riding.", skill_speed: 3, skill_before: 135, skill_after: 101},
    { number: 103, letter: "a", extra_description_number: 17, friendly_description: "From riding, pulling out the seat to seat in back.", skill_speed: 3, skill_before: 101, skill_after: 122},
    { number: 104, letter: "a", extra_description_number: 17, friendly_description: "From seat in back, getting back on the seat into riding.", skill_speed: 3, skill_before: 122, skill_after: 101},
    { number: 105, letter: "a", extra_description_number: 17, friendly_description: "From walking the wheel to riding.", skill_speed: 3, skill_before: 149, skill_after: 101},
    { number: 105, letter: "b", extra_description_number: 18, friendly_description: "From walking the wheel to riding with one foot on the pedal.", skill_speed: 3, skill_before: 149, skill_after: 140},
    { number: 105, letter: "c", extra_description_number: 17, friendly_description: "Gliding to riding.", skill_speed: 3, skill_before: 155, skill_after: 101},
    { number: 105, letter: "d", extra_description_number: 18, friendly_description: "Gliding to riding with one foot on the pedal.", skill_speed: 3, skill_before: 155, skill_after: 140},
    { number: 105, letter: "e", extra_description_number: 17, friendly_description: "From walking the wheel with one foot to riding.", skill_speed: 3, skill_before: 150, skill_after: 101},
    { number: 106, letter: "a", extra_description_number: 19, friendly_description: "From seat drag in front, picking up the frame and bringing it upright into seat in front. The frame is picked up with a hand.", skill_speed: 3, skill_before: 137, skill_after: 106},
    { number: 106, letter: "b", extra_description_number: 19, friendly_description: "From seat drag in front, picking up the frame and bringing it upright into seat in front. The frame is picked up with the toe by back pedaling slightly.", skill_speed: 3, skill_before: 137, skill_after: 106},
    { number: 106, letter: "c", extra_description_number: 19, friendly_description: "From seat drag in front, picking up the frame and bringing it upright into seat in front. The frame is picked up by lifting a foot off the pedals and placing it under the frame.", skill_speed: 3, skill_before: 137, skill_after: 106},
    { number: 107, letter: "a", extra_description_number: 41, friendly_description: "From seat drag in back, picking up the frame and bringing it upright into seat in back or seat on side. The frame is picked up with a hand.", skill_speed: 3, skill_before: 138, skill_after: 132},
    { number: 107, letter: "b", extra_description_number: 41, friendly_description: "From seat drag in back, picking up the frame and bringing it upright into seat in back or seat on side. The frame is picked up with the heel.", skill_speed: 3, skill_before: 138, skill_after: 132},
    { number: 107, letter: "c", extra_description_number: 41, friendly_description: "From seat drag in back, picking up the frame and bringing it upright into seat in back or seat on side. The frame is picked up by lifting a foot off the pedal and placing it under the frame.", skill_speed: 3, skill_before: 138, skill_after: 132},
    { number: 108, letter: "a", extra_description_number: 23, friendly_description: "From seat in front jumping into side ride.", skill_speed: 3, skill_before: 106, skill_after: 148},
    { number: 109, letter: "a", extra_description_number: 19, friendly_description: "From side ride, jumping into seat in front.", skill_speed: 3, skill_before: 148, skill_after: 106},
    { number: 110, letter: "a", extra_description_number: 22, friendly_description: "From side ride, jumping into hopping on wheel.", skill_speed: 3, skill_before: 148, skill_after: 162},
    { number: 110, letter: "b", extra_description_number: 15, friendly_description: "From side ride, jumping into sideways wheel walk.", skill_speed: 3, skill_before: 148, skill_after: 152},
    { number: 111, letter: "a", extra_description_number: 28, friendly_description: "From idling, jumping up into stand up wheel walk, removing both feet from the pedals simultaneously, and then landing both feet on the frame simultaneously.", skill_speed: 3, skill_before: 102, skill_after: 153},
    { number: 111, letter: "b", extra_description_number: 28, friendly_description: "From idling, jumping up into stand up wheel walk, removing both feet from the pedals simultaneously, and then landing both feet on the frame simultaneously. Freehanded.", skill_speed: 3, skill_before: 102, skill_after: 153},
    { number: 111, letter: "c", extra_description_number: 28, friendly_description: "From hopping, jumping up into stand up wheel walk, removing both feet from the pedals simultaneously, and then landing both feet on the frame simultaneously.", skill_speed: 3, skill_before: 161, skill_after: 153},
    { number: 111, letter: "d", extra_description_number: 28, friendly_description: "From hopping, jumping up into stand up wheel walk, removing both feet from the pedals simultaneously, and then landing both feet on the frame simultaneously. Freehanded.", skill_speed: 3, skill_before: 161, skill_after: 153},
    { number: 111, letter: "e", extra_description_number: 28, friendly_description: "From stillstand, jumping up into stand up wheel walk, removing both feet from the pedals simultaneously, and then landing both feet on the frame simultaneously.", skill_speed: 3, skill_before: 164, skill_after: 153},
    { number: 111, letter: "f", extra_description_number: 28, friendly_description: "From stillstand, jumping up into stand up wheel walk, removing both feet from the pedals simultaneously, and then landing both feet on the frame simultaneously. Freehanded.", skill_speed: 3, skill_before: 164, skill_after: 153},
    { number: 111, letter: "g", extra_description_number: 28, friendly_description: "From riding, jumping up into stand up wheel walk, removing both feet from the pedals simultaneously, and then landing both feet on the frame simultaneously.", skill_speed: 3, skill_before: 101, skill_after: 153},
    { number: 111, letter: "h", extra_description_number: 28, friendly_description: "From riding, jumping up into stand up wheel walk, removing both feet from the pedals simultaneously, and then landing both feet on the frame simultaneously. Freehanded.", skill_speed: 3, skill_before: 101, skill_after: 153},
    { number: 111, letter: "i", extra_description_number: 28, friendly_description: "From riding backward, jumping up into stand up koosh koosh, removing both feet from the pedals simultaneously, and then landing both feet on the frame simultaneously.", skill_speed: 3, skill_before: 105, skill_after: 154},
    { number: 111, letter: "j", extra_description_number: 28, friendly_description: "From riding backward, jumping up into stand up koosh koosh, removing both feet from the pedals simultaneously, and then landing both feet on the frame simultaneously. Freehanded.", skill_speed: 3, skill_before: 105, skill_after: 154},
    { number: 112, letter: "a", extra_description_number: 20, friendly_description: "From riding with one foot on pedal into stand up gliding or stand up gliding, foot on frame.", skill_speed: 3, skill_before: 140, skill_after: 158},
    { number: 112, letter: "b", extra_description_number: 20, friendly_description: "From riding with one foot on pedal into stand up gliding or stand up gliding, foot on frame. Freehanded.", skill_speed: 3, skill_before: 140, skill_after: 158},
    { number: 112, letter: "c", extra_description_number: 20, friendly_description: "From gliding into stand up gliding or stand up gliding, foot on frame.", skill_speed: 3, skill_before: 155, skill_after: 158},
    { number: 112, letter: "d", extra_description_number: 20, friendly_description: "From gliding into stand up gliding or stand up gliding, foot on frame. Freehanded.", skill_speed: 3, skill_before: 155, skill_after: 158},
    { number: 112, letter: "e", extra_description_number: 20, friendly_description: "From riding, jumping up and removing both feet from the pedals simultaneously into stand up gliding or stand up gliding, foot on frame.", skill_speed: 3, skill_before: 101, skill_after: 158},
    { number: 112, letter: "f", extra_description_number: 20, friendly_description: "From riding, jumping up and removing both feet from the pedals simultaneously into stand up gliding or stand up gliding, foot on frame. Freehanded.", skill_speed: 3, skill_before: 101, skill_after: 158},
    { number: 113, letter: "a", extra_description_number: 20, friendly_description: "From riding backward with one foot on pedal, into stand up gliding bwd or stand up gliding bwd, foot on frame.", skill_speed: 3, skill_before: 142, skill_after: 159},
    { number: 113, letter: "b", extra_description_number: 20, friendly_description: "From riding backward with one foot on pedal, into stand up gliding bwd or stand up gliding bwd, foot on frame. Freehanded.", skill_speed: 3, skill_before: 142, skill_after: 159},
    { number: 113, letter: "c", extra_description_number: 20, friendly_description: "From gliding backward into stand up gliding bwd or stand up gliding bwd, foot on frame.", skill_speed: 3, skill_before: 156, skill_after: 159},
    { number: 113, letter: "d", extra_description_number: 20, friendly_description: "From gliding backward into stand up gliding bwd or stand up gliding bwd, foot on frame. Freehanded.", skill_speed: 3, skill_before: 156, skill_after: 159},
    { number: 113, letter: "e", extra_description_number: 20, friendly_description: "From riding backward, jumping up and removing both feet from the pedals simultaneously into stand up gliding bwd or stand up gliding bwd, foot on frame.", skill_speed: 3, skill_before: 105, skill_after: 159},
    { number: 113, letter: "f", extra_description_number: 20, friendly_description: "From riding backward, jumping up and removing both feet from the pedals simultaneously into stand up gliding bwd or stand up gliding bwd, foot on frame. Freehanded.", skill_speed: 3, skill_before: 105, skill_after: 159},
    { number: 114, letter: "a", extra_description_number: 22, friendly_description: "From stand up ww, change position of the feet on the frame into stand up hopping on wheel freehanded. Freehanded.", skill_speed: 3, skill_before: 153, skill_after: 163},
    { number: 114, letter: "b", extra_description_number: 15, friendly_description: "From hop on wheel freehanded, change position of the feet on the frame into stand up ww. Freehanded. ", skill_speed: 3, skill_before: 163, skill_after: 153},
    { number: 115, letter: "a", extra_description_number: 17, friendly_description: "From walking the wheel to crossover.", skill_speed: 3, skill_before: 149, skill_after: 146},
    { number: 115, letter: "b", extra_description_number: 17, friendly_description: "From walking the wheel one foot to crossover.", skill_speed: 3, skill_before: 150, skill_after: 146},
    { number: 115, letter: "c", extra_description_number: 17, friendly_description: "From gliding to crossover.", skill_speed: 3, skill_before: 155, skill_after: 146},
    { number: 116, letter: "a", extra_description_number: 15, friendly_description: "From crossover to walking the wheel.", skill_speed: 3, skill_before: 146, skill_after: 149},
    { number: 116, letter: "b", extra_description_number: 15, friendly_description: "From crossover to walking the wheel one foot.", skill_speed: 3, skill_before: 146, skill_after: 150},
    { number: 151, letter: "a", extra_description_number: nil, friendly_description: "Riding, rotating 90 degrees around a vertical axis and continuing riding.", skill_speed: 3, skill_before: 101, skill_after: 101},
    { number: 151, letter: "b", extra_description_number: nil, friendly_description: "Riding, rotating 180 degrees around a vertical axis and continuing riding.", skill_speed: 3, skill_before: 101, skill_after: 101},
    { number: 151, letter: "c", extra_description_number: nil, friendly_description: "Riding, rotating 360 degrees around a vertical axis and continuing riding in the same direction.", skill_speed: 3, skill_before: 101, skill_after: 101},
    { number: 152, letter: "a", extra_description_number: nil, friendly_description: "Riding backward, rotating 90 degrees around a vertical axis and continuing riding backward.", skill_speed: 3, skill_before: 105, skill_after: 105},
    { number: 152, letter: "b", extra_description_number: nil, friendly_description: "Riding backward, rotating 180 degrees around a vertical axis and continuing riding backward.", skill_speed: 3, skill_before: 105, skill_after: 105},
    { number: 152, letter: "c", extra_description_number: nil, friendly_description: "Riding backward, rotating 360 degrees around a vertical axis and continuing riding backward in the same direction.", skill_speed: 3, skill_before: 105, skill_after: 105},
    { number: 153, letter: "a", extra_description_number: nil, friendly_description: "Stand up gliding, rotating 360 degrees around a vertical axis. Arms are pulled in towards the body during the turn.", skill_speed: 3, skill_before: 158, skill_after: 158},
    { number: 153, letter: "b", extra_description_number: nil, friendly_description: "Stand up gliding, rotating 360 degrees around a vertical axis.", skill_speed: 3, skill_before: 158, skill_after: 158},
    { number: 153, letter: "c", extra_description_number: nil, friendly_description: "Stand up gliding, rotating 540 degrees (1.5x) around a vertical axis. Arms are pulled in towards the body during the turn.", skill_speed: 3, skill_before: 158, skill_after: 158},
    { number: 153, letter: "d", extra_description_number: nil, friendly_description: "Stand up gliding, rotating 540 degrees (1.5x) around a vertical axis.", skill_speed: 3, skill_before: 158, skill_after: 158},
    { number: 153, letter: "e", extra_description_number: nil, friendly_description: "Stand up gliding, rotating 720 degrees (2x) around a vertical axis. Arms are pulled in towards the body during the turn.", skill_speed: 3, skill_before: 158, skill_after: 158},
    { number: 153, letter: "f", extra_description_number: nil, friendly_description: "Stand up gliding, rotating 720 degrees (2x) around a vertical axis.", skill_speed: 3, skill_before: 158, skill_after: 158},
    { number: 153, letter: "g", extra_description_number: nil, friendly_description: "Stand up gliding, rotating 900 degrees (2.5x) around a vertical axis. Arms are pulled in towards the body during the turn.", skill_speed: 2, skill_before: 158, skill_after: 158},
    { number: 153, letter: "h", extra_description_number: nil, friendly_description: "Stand up gliding, rotating 900 degrees (2.5x) around a vertical axis.", skill_speed: 2, skill_before: 158, skill_after: 158},
    { number: 153, letter: "i", extra_description_number: nil, friendly_description: "Stand up gliding, rotating 1080 degrees (3x) around a vertical axis. Arms are pulled in towards the body during the turn.", skill_speed: 2, skill_before: 158, skill_after: 158},
    { number: 153, letter: "j", extra_description_number: nil, friendly_description: "Stand up gliding, rotating 1080 degrees (3x) around a vertical axis.", skill_speed: 2, skill_before: 158, skill_after: 158},
    { number: 154, letter: "a", extra_description_number: nil, friendly_description: "Riding, rotating 180 degrees around a vertical axis and continuing riding backward in the same direction.", skill_speed: 3, skill_before: 101, skill_after: 105},
    { number: 154, letter: "b", extra_description_number: nil, friendly_description: "Riding with the seat in front, rotating 180 degrees around a vertical axis and continuing riding backward in the same direction. The seat or hand holding the seat may rest against the rider.", skill_speed: 3, skill_before: 106, skill_after: 120},
    { number: 154, letter: "c", extra_description_number: 5, friendly_description: "Riding with the seat in front, rotating 180 degrees around a vertical axis and continuing riding backward in the same direction.", skill_speed: 3, skill_before: 109, skill_after: 121},
    { number: 154, letter: "d", extra_description_number: nil, friendly_description: "Riding with the seat in back, rotating 180 degrees around a vertical axis and continuing riding backward in the same direction. The seat or hand holding the seat may rest against the rider.", skill_speed: 3, skill_before: 122, skill_after: 130},
    { number: 154, letter: "e", extra_description_number: 5, friendly_description: "Riding with the seat in back, rotating 180 degrees around a vertical axis and continuing riding backward in the same direction.", skill_speed: 3, skill_before: 125, skill_after: 131},
    { number: 154, letter: "f", extra_description_number: nil, friendly_description: "Riding with one foot on the pedal, rotating 180 degrees around a vertical axis and continuing riding backward in the same direction.", skill_speed: 3, skill_before: 140, skill_after: 142},
    { number: 155, letter: "a", extra_description_number: nil, friendly_description: "Riding backwards, rotating 180 degrees around a vertical axis and continuing riding forward in the same direction.", skill_speed: 3, skill_before: 105, skill_after: 101},
    { number: 155, letter: "b", extra_description_number: nil, friendly_description: "Riding backward with the seat in front, rotating 180 degrees around a vertical axis and continuing riding forward in the same direction. The seat or hand holding the seat may rest against the rider.", skill_speed: 3, skill_before: 120, skill_after: 106},
    { number: 155, letter: "c", extra_description_number: 5, friendly_description: "Riding backward with the seat in front, rotating 180 degrees around a vertical axis and continuing riding forward in the same direction.", skill_speed: 3, skill_before: 121, skill_after: 109},
    { number: 155, letter: "d", extra_description_number: nil, friendly_description: "Riding backward with the seat in back, rotating 180 degrees around a vertical axis and continuing riding forward in the same direction. The seat or hand holding the seat may rest against the rider.", skill_speed: 3, skill_before: 130, skill_after: 122},
    { number: 155, letter: "e", extra_description_number: 5, friendly_description: "Riding backward with the seat in back, rotating 180 degrees around a vertical axis and continuing riding forward in the same direction.", skill_speed: 3, skill_before: 131, skill_after: 125},
    { number: 155, letter: "f", extra_description_number: nil, friendly_description: "Riding backward with one foot on the pedal, rotating 180 degrees around a vertical axis and continuing riding forward in the same direction.", skill_speed: 3, skill_before: 142, skill_after: 140},
    { number: 156, letter: "a", extra_description_number: nil, friendly_description: "Standing on the frame and gliding, rotating 180 degrees around a vertical axis and continuing gliding backward in the same direction. Arms are pulled in towards the body during the turn.", skill_speed: 3, skill_before: 158, skill_after: 159},
    { number: 156, letter: "b", extra_description_number: nil, friendly_description: "Standing on the frame and gliding, rotating 180 degrees around a vertical axis and continuing gliding backward in the same direction.", skill_speed: 3, skill_before: 158, skill_after: 159},
    { number: 157, letter: "a", extra_description_number: nil, friendly_description: "Standing on the frame and gliding backward, rotating 180 degrees around a vertical axis and continuing gliding in the same direction. Arms are pulled in towards the body during the turn.", skill_speed: 3, skill_before: 159, skill_after: 158},
    { number: 157, letter: "b", extra_description_number: nil, friendly_description: "Standing on the frame and gliding backward, rotating 180 degrees around a vertical axis and continuing gliding in the same direction. Arms are pulled in towards the body during the turn.", skill_speed: 3, skill_before: 159, skill_after: 158},
    { number: 158, letter: "a", extra_description_number: 4, friendly_description: "Riding in a small circle with the upper body rotating around a vertical axis.", skill_speed: 2, skill_before: 101, skill_after: 101},
    { number: 158, letter: "b", extra_description_number: 4, friendly_description: "Riding in a small circle with the upper body rotating around a vertical axis. Riding with one foot on pedal.", skill_speed: 2, skill_before: 140, skill_after: 140},
    { number: 158, letter: "c", extra_description_number: 4, friendly_description: "Riding in a small circle with the upper body rotating around a vertical axis. Riding with one foot on pedal. The free foot is extended.", skill_speed: 2, skill_before: 141, skill_after: 141},
    { number: 159, letter: "a", extra_description_number: 4, friendly_description: "Riding backward in a small circle so that the upper body is rotating around a vertical axis.", skill_speed: 2, skill_before: 105, skill_after: 105},
    { number: 159, letter: "b", extra_description_number: 4, friendly_description: "Riding backward in a small circle so that the upper body is rotating around a vertical axis. Riding with one foot on pedal.", skill_speed: 2, skill_before: 142, skill_after: 142},
    { number: 159, letter: "c", extra_description_number: 4, friendly_description: "Riding backward in a small circle so that the upper body is rotating around a vertical axis. Riding with one foot on pedal. The free foot is extended.", skill_speed: 2, skill_before: 143, skill_after: 143},
    { number: 160, letter: "a", extra_description_number: 4, friendly_description: "Riding with one foot on pedal, rotating around a vertical axis of  the other foot on one spot. The spot may not move in any direction during the rotation once placed. One hand may hold the seat.", skill_speed: 2, skill_before: 141, skill_after: 141},
    { number: 160, letter: "b", extra_description_number: 4, friendly_description: "Riding with one foot on pedal, rotating around a vertical axis of  the other foot on one spot. The spot may not move in any direction during the rotation once placed. Without hands on the seat.", skill_speed: 2, skill_before: 141, skill_after: 141},
    { number: 160, letter: "c", extra_description_number: 4, friendly_description: "Riding with one foot on pedal, rotating around a vertical axis of  the other foot on one spot. The center foot is held with one hand with the knee bent. Freehanded.", skill_speed: 2, skill_before: 140, skill_after: 140},
    { number: 161, letter: "a", extra_description_number: 4, friendly_description: "Riding backward with one foot on pedal, rotating around a vertical axis of  the other foot on one spot. The spot may not move in any direction during the rotation once placed. One hand may hold the seat.", skill_speed: 2, skill_before: 143, skill_after: 143},
    { number: 161, letter: "b", extra_description_number: 4, friendly_description: "Riding backward with one foot on pedal, rotating around a vertical axis of  the other foot on one spot. The spot may not move in any direction during the rotation once placed. Without hands on the seat.", skill_speed: 2, skill_before: 143, skill_after: 143},
    { number: 161, letter: "c", extra_description_number: 4, friendly_description: "Riding backward with one foot on pedal, rotating around a vertical axis of  the other foot on one spot. The center foot is held with one hand with the knee bent. Freehanded.", skill_speed: 2, skill_before: 142, skill_after: 142},
    { number: 162, letter: "a", extra_description_number: 4, friendly_description: "Riding in a small circle one footed with the upper body rotating around a vertical axis and with the pedaling foot on the non-corresponding pedal. Non pedaling foot is extended and must touch the floor and may not move in any direction during the rotation once placed. ", skill_speed: 2, skill_before: 146, skill_after: 146},
    { number: 162, letter: "b", extra_description_number: 4, friendly_description: "Riding in a small circle one footed with the upper body rotating around a vertical axis and with the pedaling foot on the non-corresponding pedal. Non pedaling foot is extended. ", skill_speed: 2, skill_before: 146, skill_after: 146},
    { number: 163, letter: "a", extra_description_number: 4, friendly_description: "Riding backward in a small circle one footed with the upper body rotating around a vertical axis and with the pedaling foot on the non-corresponding pedal. Non pedaling foot is extended. ", skill_speed: 2, skill_before: 147, skill_after: 147},
    { number: 164, letter: "a", extra_description_number: 4, friendly_description: "Riding in a small circle with the seat held out in front of the rider so that the upper body is rotating around a vertical axis. The seat or the hand holding the seat may rest against the rider.", skill_speed: 2, skill_before: 106, skill_after: 106},
    { number: 164, letter: "b", extra_description_number: 32, friendly_description: "Riding in a small circle with the seat held out in front of the rider so that the upper body is rotating around a vertical axis.", skill_speed: 2, skill_before: 109, skill_after: 109},
    { number: 165, letter: "a", extra_description_number: 4, friendly_description: "Riding in a small circle with the seat held out behind the rider so that the upper body is rotating around a vertical axis. The seat or the hand holding the seat may rest against the rider.", skill_speed: 2, skill_before: 122, skill_after: 122},
    { number: 165, letter: "b", extra_description_number: 32, friendly_description: "Riding in a small circle with the seat held out behind the rider so that the upper body is rotating around a vertical axis.", skill_speed: 2, skill_before: 125, skill_after: 125},
    { number: 166, letter: "a", extra_description_number: 4, friendly_description: "Riding in a small circle so that the upper body is spinning around a vertical axis with the seat held out to the side of the rider. The seat or hand holding the seat may rest against the rider.", skill_speed: 2, skill_before: 133, skill_after: 133},
    { number: 166, letter: "b", extra_description_number: 32, friendly_description: "Riding in a small circle so that the upper body is spinning around a vertical axis with the seat held out to the side of the rider.", skill_speed: 2, skill_before: 134, skill_after: 134},
    { number: 167, letter: "a", extra_description_number: 4, friendly_description: "Spinning around a vertical axis, on momentum gained from forward movement. Arms may be pulled into the body during the pirouette and do not have to be stretched and horizontal.", skill_speed: 3, skill_before: 101, skill_after: 101},
    { number: 167, letter: "b", extra_description_number: 4, friendly_description: "Spinning around a vertical axis, on momentum gained from forward movement.", skill_speed: 3, skill_before: 101, skill_after: 101},
    { number: 168, letter: "a", extra_description_number: 4, friendly_description: "Spinning around a vertical axis on momentum gained from backward movement. Arms may be pulled into the body during the pirouette and do not have to be stretched and horizontal.", skill_speed: 3, skill_before: 105, skill_after: 105},
    { number: 168, letter: "b", extra_description_number: 4, friendly_description: "Spinning around a vertical axis on momentum gained from backward movement.", skill_speed: 3, skill_before: 105, skill_after: 105},
    { number: 169, letter: "a", extra_description_number: 4, friendly_description: "Spinning around a vertical axis with the seat held out in front of the rider. The seat or the hand holding the seat may rest against the rider. Arm may be pulled into the body during the pirouette and do not have to be stretched and horizontal.", skill_speed: 3, skill_before: 106, skill_after: 106},
    { number: 169, letter: "b", extra_description_number: 4, friendly_description: "Spinning around a vertical axis with the seat held out in front of the rider. The seat or the hand holding the seat may rest against the rider.", skill_speed: 3, skill_before: 106, skill_after: 106},
    { number: 169, letter: "c", extra_description_number: 32, friendly_description: "Spinning around a vertical axis with the seat held out in front of the rider. Arm may be pulled into the body during the pirouette and do not have to be stretched and horizontal.", skill_speed: 3, skill_before: 109, skill_after: 109},
    { number: 169, letter: "d", extra_description_number: 32, friendly_description: "Spinning around a vertical axis with the seat held out in front of the rider.", skill_speed: 3, skill_before: 109, skill_after: 109},
    { number: 170, letter: "a", extra_description_number: 4, friendly_description: "Spinning around a vertical axis with the seat held out behind the rider. The seat or the hand holding the seat may rest against the rider. Arm may be pulled into the body during the pirouette and do not have to be stretched and horizontal. ", skill_speed: 3, skill_before: 122, skill_after: 122},
    { number: 170, letter: "b", extra_description_number: 4, friendly_description: "Spinning around a vertical axis with the seat held out behind the rider. The seat or the hand holding the seat may rest against the rider.", skill_speed: 3, skill_before: 122, skill_after: 122},
    { number: 170, letter: "c", extra_description_number: 32, friendly_description: "Spinning around a vertical axis with the seat held out behind the rider. Arm may be pulled into the body during the pirouette and do not have to be stretched and horizontal. ", skill_speed: 3, skill_before: 125, skill_after: 125},
    { number: 170, letter: "d", extra_description_number: 32, friendly_description: "Spinning around a vertical axis with the seat held out behind the rider.", skill_speed: 3, skill_before: 125, skill_after: 125},
    { number: 201, letter: "a", extra_description_number: 11, friendly_description: "Bouncing with the unicycle and turning around a vertical axis over 90  degrees in one jump.", skill_speed: 3, skill_before: 161, skill_after: 161},
    { number: 201, letter: "b", extra_description_number: 11, friendly_description: "Bouncing with the unicycle and turning around a vertical axis over 180 degrees in one jump.", skill_speed: 3, skill_before: 161, skill_after: 161},
    { number: 201, letter: "c", extra_description_number: 11, friendly_description: "Bouncing with the unicycle and turning around a vertical axis over 360 degrees in one jump.", skill_speed: 3, skill_before: 161, skill_after: 161},
    { number: 201, letter: "d", extra_description_number: 11, friendly_description: "Bouncing with the unicycle and turning around a vertical axis over 90 degrees in one jump with hands free.", skill_speed: 3, skill_before: 161, skill_after: 161},
    { number: 201, letter: "e", extra_description_number: 11, friendly_description: "Bouncing with the unicycle and turning around a vertical axis over 180 degrees in one jump with hands free.", skill_speed: 3, skill_before: 161, skill_after: 161},
    { number: 201, letter: "f", extra_description_number: 11, friendly_description: "Bouncing with the unicycle and turning around a vertical axis over 360 degrees in one jump with hands free.", skill_speed: 3, skill_before: 161, skill_after: 161},
    { number: 202, letter: "a", extra_description_number: 11, friendly_description: "Riding forward and jumping around a vertical axis over 90 degrees in one jump and continue riding.", skill_speed: 3, skill_before: 101, skill_after: 101},
    { number: 202, letter: "b", extra_description_number: 11, friendly_description: "Riding forward and jumping around a vertical axis over 180  degrees in one jump and continue riding backward.", skill_speed: 3, skill_before: 101, skill_after: 105},
    { number: 202, letter: "c", extra_description_number: 11, friendly_description: "Riding forward and jumping around a vertical axis over 360 degrees in one jump and continue riding.", skill_speed: 3, skill_before: 101, skill_after: 101},
    { number: 202, letter: "d", extra_description_number: 11, friendly_description: "Riding forward and jumping around a vertical axis over 90 degrees in one jump and continue riding with hands free.", skill_speed: 3, skill_before: 101, skill_after: 101},
    { number: 202, letter: "e", extra_description_number: 11, friendly_description: "Riding forward and jumping around a vertical axis over 180  degrees in one jump and continue riding backward with hands free.", skill_speed: 3, skill_before: 101, skill_after: 105},
    { number: 202, letter: "f", extra_description_number: 11, friendly_description: "Riding forward and jumping around a vertical axis over 360  degrees in one jump and continue riding with hands free.", skill_speed: 3, skill_before: 101, skill_after: 101},
    { number: 203, letter: "a", extra_description_number: 11, friendly_description: "Hopping on wheel and turning around a vertical axis over 90 degrees in one jump.", skill_speed: 3, skill_before: 162, skill_after: 162},
    { number: 203, letter: "b", extra_description_number: 11, friendly_description: "Hopping on wheel and turning around a vertical axis over 180 degrees in one jump.", skill_speed: 3, skill_before: 162, skill_after: 162},
    { number: 203, letter: "c", extra_description_number: 11, friendly_description: "Stand up hopping on wheel freehanded, and turning around a vertical axis over 90 degrees in one jump.", skill_speed: 3, skill_before: 163, skill_after: 163},
    { number: 203, letter: "d", extra_description_number: 11, friendly_description: "Stand up hopping on wheel freehanded, and turning around a vertical axis over 180 degrees in one jump.", skill_speed: 3, skill_before: 163, skill_after: 163},
    { number: 204, letter: "a", extra_description_number: nil, friendly_description: "Hop with the unicycle over the center 50 cm circle. One or both hands may touch the seat.  With the unicycle facing the direction of travel.", skill_speed: 3, skill_before: 101, skill_after: 101},
    { number: 204, letter: "b", extra_description_number: nil, friendly_description: "Hop with the unicycle over the center 50 cm circle. One or both hands may touch the seat. With the unicycle perpendicular to the direction of travel.", skill_speed: 3, skill_before: 161, skill_after: 161},
    { number: 204, letter: "c", extra_description_number: 5, friendly_description: "Hop with the unicycle over the center 50 cm circle. One or both hands may touch the seat. With the unicycle facing the direction of travel. The seat is held in front of the rider.", skill_speed: 3, skill_before: 109, skill_after: 109},
    { number: 204, letter: "d", extra_description_number: nil, friendly_description: "Hop with the unicycle over the center 50 cm circle. One or both hands may touch the seat and seat or the hand holding the seat may rest against the rider. With the unicycle perpendicular to the direction of travel.", skill_speed: 3, skill_before: 118, skill_after: 118},
    { number: 204, letter: "e", extra_description_number: 5, friendly_description: "Hop with the unicycle over the center 50 cm circle. One or both hands may touch the seat. With the unicycle perpendicular to the direction of travel. The seat is held in front of the rider.", skill_speed: 3, skill_before: 119, skill_after: 119},
    { number: 204, letter: "f", extra_description_number: nil, friendly_description: "While hopping on wheel, hop with the unicycle over the center 50 cm circle. One or both hands may touch the seat and seat or the hand holding the seat may rest against the rider. ", skill_speed: 3, skill_before: 162, skill_after: 162},
    { number: 204, letter: "g", extra_description_number: nil, friendly_description: "While hopping on wheel freehanded, hop with the unicycle over the center 50 cm circle.", skill_speed: 3, skill_before: 163, skill_after: 163},
    { number: 205, letter: "a", extra_description_number: nil, friendly_description: "While riding, hopping, or idling, lean over and grab the tire in front of the frame with one or both hands.", skill_speed: 3, skill_before: 104, skill_after: 104},
    { number: 205, letter: "b", extra_description_number: 29, friendly_description: "While riding, hopping, or idling, lean over and grab the tire in front of the frame with one or both hands. Extend one foot off the pedals away from the unicycle before letting go of the tire.", skill_speed: 3, skill_before: 104, skill_after: 104},
    { number: 205, letter: "c", extra_description_number: 29, friendly_description: "While riding, hopping, or idling, lean over and grab the tire in front of the frame with one or both hands. Extend both feet off the pedals away from the unicycle before letting go of the tire.", skill_speed: 3, skill_before: 104, skill_after: 104},
    { number: 205, letter: "d", extra_description_number: nil, friendly_description: "While hopping seat in front, lean over and grab the tire in front of the frame with one or both hands. The seat or hand holding the seat may rest against the rider.", skill_speed: 3, skill_before: 118, skill_after: 118},
    { number: 205, letter: "e", extra_description_number: 29, friendly_description: "While hopping seat in front, lean over and grab the tire in front of the frame with one or both hands. Extend one foot off the pedals away from the unicycle before letting go of the tire. The seat or hand holding the seat may rest against the rider.", skill_speed: 3, skill_before: 118, skill_after: 118},
    { number: 205, letter: "f", extra_description_number: 29, friendly_description: "While hopping seat in front, lean over and grab the tire in front of the frame with one or both hands. Extend both feet off the pedals away from the unicycle before letting go of the tire. The seat or hand holding the seat may rest against the rider.", skill_speed: 3, skill_before: 118, skill_after: 118},
    { number: 205, letter: "g", extra_description_number: 29, friendly_description: "While hopping seat in front, lean over and grab the tire in front of the frame with one or both hands. Extend both feet off the pedals away from the unicycle before letting go of the tire. The seat or hand holding the seat may rest against the rider. Both feet are extended straight back with the legs touching each other and their angle is between parallel to the ground (completely horizontal) and 45 degrees from horizontal.", skill_speed: 3, skill_before: 118, skill_after: 118},
    { number: 206, letter: "a", extra_description_number: 19, friendly_description: "From riding with the seat in front, bouncing the seat on the floor once and catching it back. One or both hands may be used and the hands or seat may rest against the body. The unicycle is briefly released during the bounce.", skill_speed: 3, skill_before: 106, skill_after: 106},
    { number: 206, letter: "b", extra_description_number: 16, friendly_description: "From idling with the seat in front, bouncing the seat on the floor once and catching it back. One or both hands may be used and the hands or seat may rest against the body. The unicycle is briefly released during the bounce.", skill_speed: 3, skill_before: 114, skill_after: 114},
    { number: 206, letter: "c", extra_description_number: 22, friendly_description: "From hopping with the seat in front, bouncing the seat on the floor once and catching it back. One or both hands may be used and the hands or seat may rest against the body. The unicycle is briefly released during the bounce.", skill_speed: 3, skill_before: 118, skill_after: 118},
    { number: 206, letter: "d", extra_description_number: 42, friendly_description: "From riding with the seat in back, bouncing the seat on the floor once and catching it back. One or both hands may be used and the hands or seat may rest against the body. The unicycle is briefly released during the bounce.", skill_speed: 3, skill_before: 122, skill_after: 122},
    { number: 206, letter: "e", extra_description_number: 16, friendly_description: "From idling with the seat in back, bouncing the seat on the floor once and catching it back. One or both hands may be used and the hands or seat may rest against the body. The unicycle is briefly released during the bounce.", skill_speed: 3, skill_before: 126, skill_after: 126},
    { number: 206, letter: "f", extra_description_number: 22, friendly_description: "From hopping with the seat in back, bouncing the seat on the floor once and catching it back. One or both hands may be used and the hands or seat may rest against the body. The unicycle is briefly released during the bounce.", skill_speed: 3, skill_before: 128, skill_after: 128},
    { number: 207, letter: "a", extra_description_number: nil, friendly_description: "Bending down while riding, idling, or hopping seat in front, and touching the floor with the seat while holding it out in front of the rider with one hand.", skill_speed: 3, skill_before: 112, skill_after: 112},
    { number: 207, letter: "b", extra_description_number: nil, friendly_description: "Bending down while riding, idling, or hopping seat in front, and touching the floor with the seat while holding it out in front of the rider with one hand. The seat touches the floor two times before returning to riding, idling, or hopping seat in front.", skill_speed: 2, skill_before: 112, skill_after: 112},
    { number: 207, letter: "c", extra_description_number: nil, friendly_description: "Bending down while riding, idling, or hopping seat in front, and touching the floor with the seat while holding it out in front of the rider with one hand. The seat touches the floor three times before returning to riding, idling, or hopping seat in front.", skill_speed: 2, skill_before: 112, skill_after: 112},
    { number: 208, letter: "a", extra_description_number: nil, friendly_description: "Bending down and touching the floor with one hand while seated or standing on the pedals in the seated position.", skill_speed: 3, skill_before: 104, skill_after: 104},
    { number: 208, letter: "b", extra_description_number: nil, friendly_description: "Bending down and touching the floor with one hand while seated or standing on the pedals in the seated position. Both hands simultaneously touch the floor.", skill_speed: 3, skill_before: 104, skill_after: 104},
    { number: 209, letter: "a", extra_description_number: nil, friendly_description: "Bending down and touching the floor with one hand, while holding the seat out in front with the other hand.", skill_speed: 3, skill_before: 112, skill_after: 112},
    { number: 210, letter: "a", extra_description_number: nil, friendly_description: "From hopping seat in front holding the seat with one or both hands and the seat resting against the body, drop the seat forward until it rests against the forward foot. The angle of the frame must be between almost touching the ground and 45 degrees. To return the seat to the hands, lean back and flip the frame back upright with the forward foot or reach and grab with one hand..", skill_speed: 3, skill_before: 118, skill_after: 118},
    { number: 210, letter: "b", extra_description_number: nil, friendly_description: "From hopping seat in front holding the seat with one or both hands and the seat resting against the body, drop the seat forward until it rests against the forward foot. The angle of the frame must be between almost touching the ground and 45 degrees. Twist 90 degrees, then return the seat to the hands by leaning back and flip the frame back upright with the forward foot or reach and grab with one hand..", skill_speed: 2, skill_before: 118, skill_after: 118},
    { number: 211, letter: "a", extra_description_number: 29, friendly_description: "Crank idle and kick the foot that was on the pedal away from the unicycle, from 45∞ to 90∞ relative to the starting angle. The seat or the hand holding the seat may rest against the rider.", skill_speed: 3, skill_before: 160, skill_after: 160},
    { number: 211, letter: "b", extra_description_number: 36, friendly_description: "Crank idle and kick the foot that was on the pedal away from the unicycle, from 45∞ to 90∞ relative to the starting angle.", skill_speed: 3, skill_before: 160, skill_after: 160},
    { number: 211, letter: "c", extra_description_number: 29, friendly_description: "Crank idle and kick the foot that was on the pedal away from the unicycle, more than 90∞ relative to the starting angle.  The seat or the hand holding the seat may rest against the rider.", skill_speed: 3, skill_before: 160, skill_after: 160},
    { number: 211, letter: "d", extra_description_number: 36, friendly_description: "Crank idle and kick the foot that was on the pedal away from the unicycle, more than 90∞ relative to the starting angle.", skill_speed: 3, skill_before: 160, skill_after: 160},
    { number: 212, letter: "a", extra_description_number: 29, friendly_description: "Hopping on wheel, kick one leg off the wheel. Return to hopping on wheel.", skill_speed: 3, skill_before: 162, skill_after: 162},
    { number: 212, letter: "b", extra_description_number: 29, friendly_description: "Hopping on wheel, kick both legs off the wheel. Return to hopping on wheel.", skill_speed: 3, skill_before: 162, skill_after: 162},
    { number: 213, letter: "a", extra_description_number: 22, friendly_description: "From seat in front riding or hopping, jumping on the wheel into hopping on wheel.", skill_speed: 3, skill_before: 110, skill_after: 162},
    { number: 213, letter: "b", extra_description_number: 22, friendly_description: "From riding or idling, feet are placed sequentially on the wheel with one foot in front of the frame and one behind the frame into hopping on wheel.", skill_speed: 3, skill_before: 103, skill_after: 162},
    { number: 213, letter: "c", extra_description_number: 22, friendly_description: "From wheel walking, feet are placed sequentially on the wheel with one foot in front of the frame and one behind the frame into hopping on wheel.", skill_speed: 3, skill_before: 149, skill_after: 162},
    { number: 213, letter: "d", extra_description_number: 22, friendly_description: "From riding, placing one foot on the wheel in front of the frame and the other foot on the wheel behind the frame, and standing up into stand up hopping on wheel freehanded.", skill_speed: 3, skill_before: 101, skill_after: 163},
    { number: 213, letter: "e", extra_description_number: 22, friendly_description: "From seat in front riding or hopping, jumping on the wheel into hopping on wheel. The unicycle is rotated 270 around a vertical axis before the feet are placed on the tire.", skill_speed: 3, skill_before: 110, skill_after: 162},
    { number: 213, letter: "f", extra_description_number: 22, friendly_description: "From seat in front riding or hopping, jumping on the wheel into hopping on wheel. The unicycle is rotated 450 degrees around a vertical axis before the feet are placed on the tire.", skill_speed: 3, skill_before: 110, skill_after: 162},
    { number: 213, letter: "g", extra_description_number: 15, friendly_description: "From seat in front riding or hopping, jumping on the wheel into sideways wheel walk.", skill_speed: 3, skill_before: 110, skill_after: 152},
    { number: 213, letter: "h", extra_description_number: 15, friendly_description: "From seat in front riding or hopping, jumping on the wheel into sideways wheel walk. The unicycle is rotated 270 degrees around a vertical axis before the feet are placed on the tire.", skill_speed: 3, skill_before: 110, skill_after: 152},
    { number: 213, letter: "i", extra_description_number: 15, friendly_description: "From seat in front riding or hopping, jumping on the wheel into sideways wheel walk. The unicycle is rotated 450 degrees around a vertical axis before the feet are placed on the tire.", skill_speed: 3, skill_before: 110, skill_after: 152},
    { number: 214, letter: "a", extra_description_number: 17, friendly_description: "From hopping on wheel, jumping down to seat in front (with the seat touching the body) or riding.", skill_speed: 3, skill_before: 162, skill_after: 139},
    { number: 214, letter: "b", extra_description_number: 37, friendly_description: "From hopping on wheel, the feet are placed on the pedals one after the other and riding or idling.", skill_speed: 3, skill_before: 162, skill_after: 103},
    { number: 214, letter: "c", extra_description_number: 15, friendly_description: "From hopping on wheel, into wheel walking.", skill_speed: 3, skill_before: 162, skill_after: 149},
    { number: 214, letter: "d", extra_description_number: 17, friendly_description: "From stand up hopping on wheel freehanded, jumping down to riding.", skill_speed: 3, skill_before: 163, skill_after: 101},
    { number: 214, letter: "e", extra_description_number: 17, friendly_description: "From hopping on wheel, jumping down to seat in front touching the body) or riding. The unicycle is rotated 270 degrees around a vertical axis before the feet are placed on the pedals.", skill_speed: 3, skill_before: 162, skill_after: 139},
    { number: 214, letter: "f", extra_description_number: 17, friendly_description: "From hopping on wheel, jumping down to seat in front touching the body) or riding. The unicycle is rotated 450 degrees around a vertical axis before the feet are placed on the pedals.", skill_speed: 3, skill_before: 162, skill_after: 139},
    { number: 214, letter: "g", extra_description_number: 17, friendly_description: "From sideways wheel walk, without hopping, jumping or stepping down to seat in front touching the body) or riding.", skill_speed: 3, skill_before: 152, skill_after: 139},
    { number: 214, letter: "h", extra_description_number: 17, friendly_description: "From sideways wheel walk, without hopping, jumping or stepping down to seat in front or riding. The unicycle is rotated 270 degrees around a vertical axis before the feet are placed back on the pedals.", skill_speed: 3, skill_before: 152, skill_after: 139},
    { number: 215, letter: "a", extra_description_number: 38, friendly_description: "Jumping up off the uni from hopping seat in front, touching body and rotating the uni or the body 180 degrees around a vertical axis and landing back on it by sitting on the seat with the feet on the pedals or cranks. The body is allowed to rotate up to 90∞; contact with the wheel is NOT allowed.", skill_speed: 3, skill_before: 118, skill_after: 104},
    { number: 215, letter: "b", extra_description_number: 38, friendly_description: "Jumping up off the uni from hopping seat in front, touching body and rotating the uni or the body 360 degrees around a vertical axis and landing back on it by sitting on the seat with the feet on the pedals or cranks. The body is allowed to rotate up to 90∞; contact with the wheel is NOT allowed.", skill_speed: 3, skill_before: 118, skill_after: 104},
    { number: 215, letter: "c", extra_description_number: 38, friendly_description: "Jumping up off the uni from hopping seat in front, touching body and rotating the uni or the body 540 degrees around a vertical axis and landing back on it by sitting on the seat with the feet on the pedals or cranks. The body is allowed to rotate up to 90∞; contact with the wheel is NOT allowed.", skill_speed: 3, skill_before: 118, skill_after: 104},
    { number: 215, letter: "d", extra_description_number: 38, friendly_description: "Jumping up off the uni from hopping seat in front, touching body and rotating the uni or the body 720 degrees around a vertical axis and landing back on it by sitting on the seat with the feet on the pedals or cranks. The body is allowed to rotate up to 90∞; contact with the wheel is NOT allowed.", skill_speed: 3, skill_before: 118, skill_after: 104},
    { number: 215, letter: "e", extra_description_number: 38, friendly_description: "Jumping up off the uni, rotating the uni or the body 180 degrees around a vertical axis and landing back on it with the seat held in front. The body is allowed to rotate up to 90∞; contact with the wheel is NOT allowed. The seat may touch the rider and one or both hands may touch the seat.", skill_speed: 3, skill_before: 118, skill_after: 112},
    { number: 215, letter: "f", extra_description_number: 38, friendly_description: "Jumping up off the uni, rotating the uni or the body 360 degrees around a vertical axis and landing back on it with the seat held in front. The body is allowed to rotate up to 90∞; contact with the wheel is NOT allowed. The seat may touch the rider and one or both hands may touch the seat.", skill_speed: 3, skill_before: 118, skill_after: 112},
    { number: 215, letter: "g", extra_description_number: 38, friendly_description: "Jumping up off the uni, rotating the uni or the body 540 degrees around a vertical axis and landing back on it with the seat held in front. The body is allowed to rotate up to 90∞; contact with the wheel is NOT allowed. The seat may touch the rider and one or both hands may touch the seat.", skill_speed: 3, skill_before: 118, skill_after: 112},
    { number: 215, letter: "h", extra_description_number: 16, friendly_description: "Jumping up off the uni from hopping seat in front, touching body and rotating the uni or the body 180 degrees around a vertical axis and landing back on it by sitting on the seat and into idling one foot. The body is allowed to rotate up to 90∞; contact with the wheel is NOT allowed.", skill_speed: 3, skill_before: 118, skill_after: 144},
    { number: 215, letter: "i", extra_description_number: 16, friendly_description: "Jumping up off the uni from hopping seat in front, touching body and rotating the uni or the body 360 degrees around a vertical axis and landing back on it by sitting on the seat and into idling one foot. The body is allowed to rotate up to 90∞; contact with the wheel is NOT allowed.", skill_speed: 3, skill_before: 118, skill_after: 144},
    { number: 215, letter: "j", extra_description_number: 16, friendly_description: "Jumping up off the uni from hopping seat in front, touching body and rotating the uni or the body 540 degrees around a vertical axis and landing back on it by sitting on the seat and into idling one foot. The body is allowed to rotate up to 90∞; contact with the wheel is NOT allowed.", skill_speed: 3, skill_before: 118, skill_after: 144},
    { number: 215, letter: "k", extra_description_number: 16, friendly_description: "Jumping up off the uni, rotating the uni or the body 180 degrees around a vertical axis and landing back on it with the seat held in front and idling one foot. The body is allowed to rotate up to 90∞; contact with the wheel is NOT allowed. The seat may touch the rider and one or both hands may touch the seat.", skill_speed: 3, skill_before: 118, skill_after: 165},
    { number: 215, letter: "l", extra_description_number: 16, friendly_description: "Jumping up off the uni, rotating the uni or the body 360 degrees around a vertical axis and landing back on it with the seat held in front and idling one foot. The body is allowed to rotate up to 90∞; contact with the wheel is NOT allowed. The seat may touch the rider and one or both hands may touch the seat.", skill_speed: 3, skill_before: 118, skill_after: 165},
    { number: 215, letter: "m", extra_description_number: 17, friendly_description: "From riding seat in front, jumping up off the uni and rotating the uni 180∞ around a vertical axis and landing back on it by sitting on the seat with the feet on the pedals or cranks or into riding seat in front. The body is allowed to rotate up to 90∞; contact with the wheel is NOT allowed. The seat may touch the rider and one or both hands may touch the seat.", skill_speed: 3, skill_before: 106, skill_after: 101},
    { number: 215, letter: "n", extra_description_number: 17, friendly_description: "From riding seat in front, jumping up off the uni and rotating the uni 360∞ around a vertical axis and landing back on it by sitting on the seat with the feet on the pedals or cranks or into riding seat in front. The body is allowed to rotate up to 90∞; contact with the wheel is NOT allowed. The seat may touch the rider and one or both hands may touch the seat.", skill_speed: 3, skill_before: 106, skill_after: 101},
    { number: 216, letter: "a", extra_description_number: 15, friendly_description: "Jumping up off the uni, rotating it 180 degrees around a vertical axis and landing back on it in the wheel walk position.", skill_speed: 3, skill_before: 118, skill_after: 149},
    { number: 216, letter: "b", extra_description_number: 15, friendly_description: "Jumping up off the uni, rotating it 360 degrees around a vertical axis and landing back on it in the wheel walk position.", skill_speed: 3, skill_before: 118, skill_after: 149},
    { number: 216, letter: "c", extra_description_number: 15, friendly_description: "Jumping up off the uni, rotating it 180 degrees around a vertical axis and landing back on it in the wheel walk one foot position.", skill_speed: 3, skill_before: 118, skill_after: 150},
    { number: 216, letter: "d", extra_description_number: 15, friendly_description: "Jumping up off the uni, rotating it 360 degrees around a vertical axis and landing back on it in the wheel walk one foot position.", skill_speed: 3, skill_before: 118, skill_after: 150},
    { number: 217, letter: "a", extra_description_number: 22, friendly_description: "Jumping up off the uni, rotating it 180 degrees around a vertical axis, and landing back on it into hopping on wheel freehanded. When landing on the wheel, the hands must not touch the seat after the first hop.", skill_speed: 3, skill_before: 118, skill_after: 163},
    { number: 217, letter: "b", extra_description_number: 22, friendly_description: "Jumping up off the uni, rotating it 360 degrees around a vertical axis, and landing back on it into hopping on wheel freehanded. When landing on the wheel, the hands must not touch the seat after the first hop.", skill_speed: 3, skill_before: 118, skill_after: 163},
    { number: 218, letter: "a", extra_description_number: 22, friendly_description: "From hopping on wheel, jumping up off the unicycle, rotating it 180 degrees around a vertical axis, and landing back on it into hopping on wheel.", skill_speed: 3, skill_before: 162, skill_after: 162},
    { number: 218, letter: "b", extra_description_number: 22, friendly_description: "From hopping on wheel, jumping up off the unicycle, rotating it 360 degrees around a vertical axis, and landing back on it into hopping on wheel.", skill_speed: 3, skill_before: 162, skill_after: 162},
    { number: 219, letter: "a", extra_description_number: 17, friendly_description: "From riding with one or both hands holding the seat, jump up and rotate the wheel without the feet leaving the pedals so it will do a complete rotation before landing. The wheel may rotate forwards or backwards.", skill_speed: 3, skill_before: 101, skill_after: 101},
    { number: 219, letter: "b", extra_description_number: 17, friendly_description: "From riding with one or both hands holding the seat, jump up and after leaving the ground, push the front pedal or back pedal so the wheel will do a complete rotation, remove both feet from the pedals, before finally landing with feet on the pedals in the same relative position as they started. The wheel may rotate forwards or backwards.", skill_speed: 3, skill_before: 101, skill_after: 101},
    { number: 219, letter: "c", extra_description_number: 17, friendly_description: "From riding with one or both hands holding the seat, jump up and after leaving the ground, push the front pedal or back pedal so the wheel will do two complete rotations, remove both feet from the pedals, before finally landing with feet on the pedals in the same relative position as they started. The wheel may rotate forwards or backwards.", skill_speed: 3, skill_before: 101, skill_after: 101},
    { number: 219, letter: "d", extra_description_number: 17, friendly_description: "From riding with one or both hands holding the seat, jump up and after leaving the ground, push the front pedal or back pedal so the wheel will do three complete rotations, remove both feet from the pedals, before finally landing with feet on the pedals in the same relative position as they started. The wheel may rotate forwards or backwards.", skill_speed: 3, skill_before: 101, skill_after: 101},
    { number: 219, letter: "e", extra_description_number: 38, friendly_description: "From riding seat in front with one or both hands holding the seat, jump up and after leaving the ground, push the front pedal or back pedal so the wheel will do a complete rotation, remove both feet from the pedals, before finally landing with feet on the pedals in the same relative position as they started. The wheel may rotate forwards or backwards. The seat or the hand holding the seat may rest against the rider. ", skill_speed: 3, skill_before: 106, skill_after: 106},
    { number: 219, letter: "f", extra_description_number: 38, friendly_description: "From riding seat in front with one or both hands holding the seat, jump up and after leaving the ground, push the front pedal or back pedal so the wheel will do two complete rotations, remove both feet from the pedals, before finally landing with feet on the pedals in the same relative position as they started. The wheel may rotate forwards or backwards. The seat or the hand holding the seat may rest against the rider. ", skill_speed: 3, skill_before: 106, skill_after: 106},
    { number: 219, letter: "g", extra_description_number: 38, friendly_description: "From riding seat in front with one or both hands holding the seat, jump up and after leaving the ground, push the front pedal or back pedal so the wheel will do three complete rotations, remove both feet from the pedals, before finally landing with feet on the pedals in the same relative position as they started. The wheel may rotate forwards or backwards. The seat or the hand holding the seat may rest against the rider. ", skill_speed: 3, skill_before: 106, skill_after: 106},
    { number: 220, letter: "a", extra_description_number: 38, friendly_description: "From riding or hopping seat in front, jump up and then in mid-air push the front pedal so the wheel will do a complete rotation, simultaneously rotating the unicycle 180 degrees, and landing with feet on the pedals. The rider lands either sitting on the seat or seat in front. If the seat is in front, one or both hands may touch the seat and the seat may rest against the body. ", skill_speed: 3, skill_before: 110, skill_after: 139},
    { number: 220, letter: "b", extra_description_number: 38, friendly_description: "From riding or hopping seat in front, jump up and then in mid-air push the front pedal so the wheel will do a complete rotation, simultaneously rotating the unicycle 360 degrees, and landing with feet on the pedals. The rider lands either sitting on the seat or seat in front. If the seat is in front, one or both hands may touch the seat and the seat may rest against the body. ", skill_speed: 3, skill_before: 110, skill_after: 139},
    { number: 220, letter: "c", extra_description_number: 38, friendly_description: "From riding or hopping seat in front, jump up and then in mid-air push the front pedal so the wheel will do a complete rotation, simultaneously rotating the unicycle 540 degrees, and landing with feet on the pedals. The rider lands either sitting on the seat or seat in front. If the seat is in front, one or both hands may touch the seat and the seat may rest against the body. ", skill_speed: 3, skill_before: 110, skill_after: 139},
    { number: 220, letter: "d", extra_description_number: 38, friendly_description: "From riding or hopping seat in front, jump up and then in mid-air push the front pedal so the wheel will do two complete rotations, simultaneously rotating the unicycle 180 degrees, and landing with feet on the pedals. The rider lands either sitting on the seat or seat in front. If the seat is in front, one or both hands may touch the seat and the seat may rest against the body. ", skill_speed: 3, skill_before: 110, skill_after: 139},
    { number: 220, letter: "e", extra_description_number: 38, friendly_description: "From riding or hopping seat in front, jump up and then in mid-air push the front pedal so the wheel will do two complete rotations, simultaneously rotating the unicycle 360 degrees, and landing with feet on the pedals. The rider lands either sitting on the seat or seat in front. If the seat is in front, one or both hands may touch the seat and the seat may rest against the body. ", skill_speed: 3, skill_before: 110, skill_after: 139},
    { number: 220, letter: "f", extra_description_number: 38, friendly_description: "From riding or hopping seat in front, jump up and then in mid-air push the front pedal so the wheel will do two complete rotations, simultaneously rotating the unicycle 540 degrees, and landing with feet on the pedals. The rider lands either sitting on the seat or seat in front. If the seat is in front, one or both hands may touch the seat and the seat may rest against the body. ", skill_speed: 3, skill_before: 110, skill_after: 139},
    { number: 221, letter: "a", extra_description_number: 38, friendly_description: "From hopping seat in front with the seat touching the body and holding with one or both hands, jump up and land with one foot resting on the wheel and the other on the crown of the frame. Push the wheel so it rotates backwards a full revolution before landing back on the pedals into hopping seat in front, touching the body. ", skill_speed: 3, skill_before: 118, skill_after: 118},
    { number: 222, letter: "a", extra_description_number: 38, friendly_description: "From riding, swinging one leg first around the back of the seat then around the front of the seat to riding.", skill_speed: 3, skill_before: 104, skill_after: 104},
    { number: 222, letter: "b", extra_description_number: 38, friendly_description: "From riding, swinging one leg first around the back of the seat then around the front of the seat to riding. The leg goes once around the back of the seat and the front of the seat a second time before the foot is placed back on the pedal.", skill_speed: 3, skill_before: 104, skill_after: 104},
    { number: 222, letter: "c", extra_description_number: 16, friendly_description: "From riding, swinging one leg over the front of the seat into idling seat on side, touching body. Only one hand is used.", skill_speed: 3, skill_before: 104, skill_after: 166},
    { number: 222, letter: "d", extra_description_number: 16, friendly_description: "From riding, swinging one leg over the front of the seat into idling seat on side, touching body. Two hands may be used.", skill_speed: 3, skill_before: 104, skill_after: 166},
    { number: 222, letter: "e", extra_description_number: 16, friendly_description: "From riding, swinging one leg over the front of the seat into crank idle, seat against body. Only one hand is used.", skill_speed: 3, skill_before: 104, skill_after: 160},
    { number: 222, letter: "f", extra_description_number: 16, friendly_description: "From riding, swinging one leg over the front of the seat into crank idle, seat against body. Two hands may be used.", skill_speed: 3, skill_before: 104, skill_after: 160},
    { number: 222, letter: "g", extra_description_number: 16, friendly_description: "From riding, swinging one leg around the back of the seat into crank idle, seat against body. One or two hands may be used.", skill_speed: 3, skill_before: 104, skill_after: 160},
    { number: 222, letter: "h", extra_description_number: 38, friendly_description: "From riding, swinging one leg around the back of the seat, then the leg and body around to the front of the seat into seat in back. One or two hands may be used.", skill_speed: 3, skill_before: 104, skill_after: 167},
    { number: 223, letter: "a", extra_description_number: 38, friendly_description: "From seat on side, swinging one leg around the front of the seat to riding. One or two hands may be used.", skill_speed: 3, skill_before: 168, skill_after: 104},
    { number: 223, letter: "b", extra_description_number: 16, friendly_description: "From seat on side, swinging one leg around the front of the wheel into crank idle. One or two hands may be used.", skill_speed: 3, skill_before: 168, skill_after: 160},
    { number: 223, letter: "c", extra_description_number: 38, friendly_description: "From seat on side, swinging one leg around the front of the seat into seat in front. One or two hands may be used.", skill_speed: 3, skill_before: 168, skill_after: 112},
    { number: 223, letter: "d", extra_description_number: 38, friendly_description: "From seat on side, swinging one leg around the back of the seat into seat in front. One or two hands may be used.", skill_speed: 3, skill_before: 168, skill_after: 112},
    { number: 223, letter: "e", extra_description_number: 22, friendly_description: "From seat on side, the leg goes around the front of the wheel and jumps into side hopping. One or two hands may be used.", skill_speed: 3, skill_before: 168, skill_after: 168},
    { number: 224, letter: "a", extra_description_number: 38, friendly_description: "From crank idle, swinging one leg around the front of the seat to idling. One hand is on the seat.", skill_speed: 3, skill_before: 160, skill_after: 104},
    { number: 224, letter: "b", extra_description_number: 16, friendly_description: "From crank idle, swinging one leg around the front of the seat to idling. Freehanded.", skill_speed: 3, skill_before: 160, skill_after: 104},
    { number: 224, letter: "c", extra_description_number: 16, friendly_description: "From crank idle, swinging one leg around the front of the seat to idling one foot. One or two hands may be used.", skill_speed: 3, skill_before: 160, skill_after: 144},
    { number: 224, letter: "d", extra_description_number: 16, friendly_description: "From crank idle, swinging one leg around the front of the wheel to seat on side idling, touching body. One or two hands may be used.", skill_speed: 3, skill_before: 160, skill_after: 144},
    { number: 224, letter: "e", extra_description_number: 16, friendly_description: "From crank idle, the leg goes around the front of the seat into seat in front idling. One or two hands may be used.", skill_speed: 3, skill_before: 160, skill_after: 112},
    { number: 224, letter: "f", extra_description_number: 16, friendly_description: "From crank idle, the leg goes around the front of the seat, then around the back of the seat into crank idling. One or two hands may be used.", skill_speed: 3, skill_before: 160, skill_after: 160},
    { number: 224, letter: "g", extra_description_number: 22, friendly_description: "From crank idle, jumping into side hopping or side hopping, foot touching tire. One or two hands may be used.", skill_speed: 3, skill_before: 160, skill_after: 169},
    { number: 224, letter: "h", extra_description_number: 22, friendly_description: "From crank idle, into hopping on wheel by stepping onto the wheel. One or two hands may be used.", skill_speed: 3, skill_before: 160, skill_after: 162},
    { number: 224, letter: "i", extra_description_number: 22, friendly_description: "From crank idle, into hopping on wheel by hopping onto the wheel. One or two hands may be used.", skill_speed: 3, skill_before: 160, skill_after: 162},
    { number: 225, letter: "a", extra_description_number: 38, friendly_description: "From seat in front with the seat touching the body, swinging one leg first around the back of the seat then around the front of the seat to riding. One or two hands may be used.", skill_speed: 3, skill_before: 112, skill_after: 104},
    { number: 225, letter: "b", extra_description_number: 38, friendly_description: "From seat in front, swinging one leg around the seat to seat in back or riding. The leg goes once around the seat before the foot is placed back on the pedal. The leg goes one additional time around the seat before the foot is placed back on the pedal. One or two hands may be used.", skill_speed: 3, skill_before: 112, skill_after: 104},
    { number: 225, letter: "c", extra_description_number: 38, friendly_description: "From seat in front with the seat touching the body, swinging one leg first around the back of the seat then around the front of the seat into seat in front. One or two hands may be used.", skill_speed: 3, skill_before: 112, skill_after: 112},
    { number: 225, letter: "d", extra_description_number: 16, friendly_description: "From seat in front with the seat touching the body, swinging one leg first around the back of the seat then pulling the seat to one side of the body as the second foot is placed on the pedal into idling seat on side, touching body. One or two hands may be used.", skill_speed: 3, skill_before: 112, skill_after: 168},
    { number: 225, letter: "e", extra_description_number: 16, friendly_description: "From seat in front with the seat touching the body, swinging one leg first around the back of the seat then pulling the seat to one side of the body as the second foot is placed on the crank arm into crank idle, seat against body. One or two hands may be used.", skill_speed: 3, skill_before: 112, skill_after: 160},
    { number: 225, letter: "f", extra_description_number: 38, friendly_description: "From seat in front with the seat touching the body, swinging one leg first around the back of the seat then the leg and body around to the front of the seat into seat in back. One or two hands may be used.", skill_speed: 3, skill_before: 112, skill_after: 167},
    { number: 226, letter: "a", extra_description_number: 38, friendly_description: "From seat in back, swinging one leg first around the front of the seat then the back of the seat to riding. One or two hands may be used.", skill_speed: 3, skill_before: 167, skill_after: 104},
    { number: 226, letter: "b", extra_description_number: 38, friendly_description: "From seat in back, swinging one leg first around the front of the seat then the back of the seat to riding. The leg goes once around the seat before the foot is placed back on the pedal. One or two hands may be used.", skill_speed: 3, skill_before: 167, skill_after: 104},
    { number: 227, letter: "a", extra_description_number: 37, friendly_description: "From seat in front the rider steps around the uni, without the uni bouncing or turning, such that the feet switch pedals. The rider ends facing the opposite way, sitting on the seat.", skill_speed: 3, skill_before: 112, skill_after: 103},
    { number: 227, letter: "b", extra_description_number: 39, friendly_description: "From seat in front hopping the rider jumps up and twists their body 180∞ before landing back on the pedals.", skill_speed: 3, skill_before: 118, skill_after: 104},
    { number: 227, letter: "c", extra_description_number: 38, friendly_description: "From seat on side the rider swings one leg in back and then steps around the uni, without the uni bouncing or turning, such that the feet switch pedals. The rider ends facing the opposite way, sitting on the seat.", skill_speed: 3, skill_before: 168, skill_after: 104},
    { number: 228, letter: "a", extra_description_number: 39, friendly_description: "Hopping with the unicycle seat in front (the seat may touch the body), turning around a vertical axis over 180 degrees in one jump, and simultaneously jumping up off the uni, rotating the unicycle relative to the riderís body 180∞ around a vertical axis and landing back on the pedals or cranks with the seat in front. The hoptwist and the unispin are in the same direction, so relative to the ground the unicycle travels 360∞", skill_speed: 3, skill_before: 118, skill_after: 110},
    { number: 228, letter: "b", extra_description_number: 39, friendly_description: "Hopping with the unicycle seat in front (the seat may touch the body), turning around a vertical axis over 180 degrees in one jump, and simultaneously jumping up off the uni, rotating the unicycle relative to the riderís body 360∞ around a vertical axis and landing back on the pedals or cranks with the seat in front. The hoptwist and the unispin are in the same direction, so relative to the ground the unicycle travels 540∞", skill_speed: 3, skill_before: 118, skill_after: 110},
    { number: 228, letter: "c", extra_description_number: 39, friendly_description: "Hopping with the unicycle seat in front (the seat may touch the body), turning around a vertical axis over 180 degrees in one jump, and simultaneously jumping up off the uni, rotating the unicycle relative to the riderís body 540∞ around a vertical axis and landing back on the pedals or cranks with the seat in front. The hoptwist and the unispin are in the same direction, so relative to the ground the unicycle travels 720∞", skill_speed: 3, skill_before: 118, skill_after: 110},
    { number: 228, letter: "d", extra_description_number: 39, friendly_description: "Hopping with the unicycle seat in front (the seat may touch the body), turning around a vertical axis over 180 degrees in one jump, and simultaneously jumping up off the uni, rotating the unicycle relative to the riderís body 360∞ around a vertical axis and landing back on the pedals or cranks with the seat in front. The hoptwist and the unispin are the opposite direction, so relative to the ground the unicycle travels 180∞", skill_speed: 3, skill_before: 118, skill_after: 110},
    { number: 228, letter: "e", extra_description_number: 39, friendly_description: "Hopping with the unicycle seat in front (the seat may touch the body), turning around a vertical axis over 180 degrees in one jump, and simultaneously jumping up off the uni, rotating the unicycle relative to the riderís body 540∞ around a vertical axis and landing back on the pedals or cranks with the seat in front. The hoptwist and the unispin are the opposite direction, so relative to the ground the unicycle travels 360∞", skill_speed: 3, skill_before: 118, skill_after: 110},
    { number: 229, letter: "a", extra_description_number: 39, friendly_description: "From riding or hopping seat in front with one or two hands on the seat and the seat touching the body, the rider jumps and spins the unicycle 180 degrees similar to a 180 unispin. During the unispin, one leg wraps all the way around the unicycle in the same direction that the unicycle is spinning (first behind the seat, then in front of the seat), and then both feet land back on to the pedals. The hand spinning the seat is originally in front of the body, but when landing back on the unicycle, the hand is in back of the body.", skill_speed: 3, skill_before: 110, skill_after: 104},
    { number: 229, letter: "b", extra_description_number: 39, friendly_description: "From riding or hopping seat in front with one or two hands on the seat and the seat touching the body, the rider jumps and spins the unicycle 360 degrees similar to a 360 unispin. During the unispin, one leg wraps all the way around the unicycle in the same direction that the unicycle is spinning (first behind the seat, then in front of the seat), and then both feet land back on to the pedals. The hand spinning the seat is originally in front of the body, but when landing back on the unicycle, the hand is in back of the body.", skill_speed: 3, skill_before: 110, skill_after: 104},
    { number: 229, letter: "c", extra_description_number: 39, friendly_description: "From riding or hopping seat in front with one or two hands on the seat and the seat touching the body, the rider jumps and spins the unicycle 540 degrees similar to a 540 unispin. During the unispin, one leg wraps all the way around the unicycle in the same direction that the unicycle is spinning (first behind the seat, then in front of the seat), and then both feet land back on to the pedals. The hand spinning the seat is originally in front of the body, but when landing back on the unicycle, the hand is in back of the body.", skill_speed: 3, skill_before: 110, skill_after: 104},
    { number: 251, letter: "a", extra_description_number: 1, friendly_description: "Staying in place by moving the wheel forward and backward centered at a vertical crank position.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 251, letter: "b", extra_description_number: 1, friendly_description: "Staying in place by moving the wheel forward and backward centered at a vertical crank position. Idling with one foot on pedal.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 251, letter: "c", extra_description_number: 1, friendly_description: "Staying in place by moving the wheel forward and backward centered at a vertical crank position. Idling with one foot on pedal and free foot extended.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 251, letter: "d", extra_description_number: 34, friendly_description: "Staying in place by moving the wheel forward and backward centered at a vertical crank position. Idling with one foot on pedal and free leg crossed over the pedaling leg.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 252, letter: "a", extra_description_number: 1, friendly_description: "Staying in place by moving the wheel forward and backward centered at a vertical crank position with the seat held in front of the rider. The seat or hand holding the seat may rest against the rider.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 252, letter: "b", extra_description_number: 26, friendly_description: "Staying in place by moving the wheel forward and backward centered at a vertical crank position with the seat held in front of the rider.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 252, letter: "c", extra_description_number: 1, friendly_description: "Staying in place by moving the wheel forward and backward centered at a vertical crank position with the seat held in front of the rider. The seat or hand holding the seat may rest against the rider. Idling with one foot on pedal.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 252, letter: "d", extra_description_number: 26, friendly_description: "Staying in place by moving the wheel forward and backward centered at a vertical crank position with the seat held in front of the rider. Idling with one foot on pedal.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 252, letter: "e", extra_description_number: 1, friendly_description: "Staying in place by moving the wheel forward and backward centered at a vertical crank position with the seat held in front of the rider. The seat or hand holding the seat may rest against the rider. Idling with one foot on pedal and free foot extended", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 252, letter: "f", extra_description_number: 1, friendly_description: "Staying in place by moving the wheel forward and backward centered at a vertical crank position with the seat held in back of the rider. The seat or hand holding the seat may rest against the rider.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 252, letter: "g", extra_description_number: 26, friendly_description: "Staying in place by moving the wheel forward and backward centered at a vertical crank position with the seat held in back of the rider.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 253, letter: "a", extra_description_number: 1, friendly_description: "Idling with the seat held out to the side of the rider. The seat may touch the riderís body.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 253, letter: "b", extra_description_number: 1, friendly_description: "Idling with the seat on the side of the rider. The seat may touch the riderís body but neither hand may touch the seat.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 253, letter: "c", extra_description_number: 26, friendly_description: "Idling with the seat held out to the side of the rider. The rider shall have no contact with the seat other than one hand holding the seat.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 253, letter: "d", extra_description_number: 1, friendly_description: "Idling with one foot on the pedal and with the seat held out to the side of the rider. The seat may touch the riderís body.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 253, letter: "e", extra_description_number: 26, friendly_description: "Idling with one foot on the pedal and with the seat held out to the side of the rider. The rider shall have no contact with the seat other than one hand holding the seat.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 253, letter: "f", extra_description_number: 1, friendly_description: "Idling with one foot on the pedal and with the seat held out to the side of the rider. The seat may touch the riderís body. The free leg is extended.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 253, letter: "g", extra_description_number: 26, friendly_description: "Idling with one foot on the pedal and with the seat held out to the side of the rider. The rider shall have no contact with the seat other than one hand holding the seat. The free leg is extended.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 253, letter: "h", extra_description_number: 1, friendly_description: "Idling with the seat out to the side of the rider. idling with one foot on the non-corresponding pedal with the seat on side, holding the seat with both hands. The seat or the hands holding the seat may rest against the rider.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 253, letter: "i", extra_description_number: 1, friendly_description: "Idling with the seat out to the side of the rider. idling with one foot on the non-corresponding pedal with the seat on side, holding the seat with one hand. The seat or the hand holding the seat may rest against the rider.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 254, letter: "a", extra_description_number: 1, friendly_description: "Staying in place, on one side of the unicycle, by moving the wheel forward and backward centered at a vertical crank position. One foot is on the pedal while the other foot is resting on top of the crank arm on the same side. The seat or one hand holding the seat may rest against the rider.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 254, letter: "b", extra_description_number: 1, friendly_description: "Staying in place, on one side of the unicycle, by moving the wheel forward and backward centered at a vertical crank position. One foot is on the pedal while the other foot is resting on top of the crank arm on the same side. The seat may rest against the rider but neither hand may touch the seat.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 254, letter: "c", extra_description_number: 26, friendly_description: "Staying in place, on one side of the unicycle, by moving the wheel forward and backward centered at a vertical crank position. One foot is on the pedal while the other foot is resting on top of the crank arm on the same side. The rider shall have no contact with the seat other than one hand holding the seat.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 255, letter: "a", extra_description_number: 1, friendly_description: "Staying in place by moving the wheel forward and backward with the feet on the wheel. One foot is in front of the frame and one is in back of the frame.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 255, letter: "b", extra_description_number: 1, friendly_description: "Staying in place by moving the wheel forward and backward with one foot on the wheel.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 255, letter: "c", extra_description_number: 1, friendly_description: "Staying in place by moving the wheel forward and backward with one foot on the wheel. The free leg is extended.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 256, letter: "a", extra_description_number: 3, friendly_description: "Staying in place twisting the unicycle left and right around a vertical axis.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 257, letter: "a", extra_description_number: 2, friendly_description: "Staying in place with no wheel movement.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 258, letter: "a", extra_description_number: 43, friendly_description: "Bouncing with the unicycle with one hand holding on to the seat.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 258, letter: "b", extra_description_number: 6, friendly_description: "Bouncing with the unicycle with both hands are free.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 259, letter: "a", extra_description_number: 43, friendly_description: "Hopping with the unicycle with the seat held in front of the rider. The seat or the hand holding the seat may rest against the rider.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 259, letter: "b", extra_description_number: 44, friendly_description: "Hopping with the unicycle with the seat held in front of the rider.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 259, letter: "c", extra_description_number: 6, friendly_description: "Hopping with the unicycle with the seat held in front of the rider. The seat or the hand holding the seat may rest against the rider. The seat is held in back of the rider.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 259, letter: "d", extra_description_number: 27, friendly_description: "Hopping with the unicycle with the seat held in front of the rider. The seat is held in back of the rider.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 260, letter: "a", extra_description_number: 6, friendly_description: "Hopping, standing on wheel with one foot in front of and the other behind frame, holding on to the seat with both hands.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 260, letter: "b", extra_description_number: 6, friendly_description: "Hopping, sitting on the seat with one or both feet on the wheel. One hand may be holding the seat.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 260, letter: "c", extra_description_number: 6, friendly_description: "Hopping, sitting on the seat with one or both feet on the wheel. Freehanded.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 260, letter: "d", extra_description_number: 6, friendly_description: "Hopping, standing on wheel with one foot in front of and the other behind the frame, and the seat between the legs. One hand holding on to the seat.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 260, letter: "e", extra_description_number: 6, friendly_description: "Hopping, standing on wheel with one foot in front of and the other behind the frame, and the seat between the legs. Not holding on to the seat.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 261, letter: "a", extra_description_number: 3, friendly_description: "Staying in place bouncing the unicycle left then right around a vertical axis. A minimum of 5 consecutive cycles (left and right bounces) must be executed. Neither hand may touch the seat.", skill_speed: 2, skill_before: nil, skill_after: nil},
    { number: 262, letter: "a", extra_description_number: 9, friendly_description: "Hopping 1ft, next to the unicycle, with foot on the non-corresponding pedal holding on to the seat with either one or both hands. The free foot is extended.", skill_speed: 3, skill_before: nil, skill_after: nil},
    { number: 262, letter: "b", extra_description_number: 6, friendly_description: "Hopping 1ft, next to the unicycle, with foot on the non-corresponding pedal holding on to the seat with either one or both hands. The free foot is touching the tire for balance.", skill_speed: 3, skill_before: nil, skill_after: nil},
    { number: 301, letter: "a", extra_description_number: 17, friendly_description: "Mounting the uni from standing behind it, by placing one foot on the rear pedal and going up and over the wheel or rotating the wheel backward to obtain balance. One hand is touching the seat.", skill_speed: 3, skill_before: nil, skill_after: 101},
    { number: 301, letter: "b", extra_description_number: 17, friendly_description: "Mounting the uni from standing behind it, by placing one foot on the rear pedal and going up and over the wheel or rotating the wheel backward to obtain balance.", skill_speed: 3, skill_before: nil, skill_after: 101},
    { number: 301, letter: "c", extra_description_number: 16, friendly_description: "Mounting the uni from standing behind it, by placing one foot on the rear pedal and going up and over the wheel or rotating the wheel backward to obtain balance, mounting to idling without riding.", skill_speed: 2, skill_before: nil, skill_after: 102},
    { number: 301, letter: "d", extra_description_number: 16, friendly_description: "Mounting the uni from standing behind it, by placing one foot on the rear pedal and going up and over the wheel or rotating the wheel backward to obtain balance, mounting into idling with only one foot on pedal.", skill_speed: 2, skill_before: nil, skill_after: 144},
    { number: 301, letter: "e", extra_description_number: 16, friendly_description: "Mounting the uni from standing behind it, by placing one foot on the rear pedal and going up and over the wheel or rotating the wheel backward to obtain balance, mounting into idling with only one foot on pedal the free leg is extended.", skill_speed: 2, skill_before: nil, skill_after: 145},
    { number: 302, letter: "a", extra_description_number: 17, friendly_description: "Mounting the uni while pushing the uni forward, by placing one foot on the rear pedal and going up and over the wheel, without the wheel pausing, stopping or going backwards and continue riding forward.", skill_speed: 3, skill_before: nil, skill_after: 101},
    { number: 302, letter: "b", extra_description_number: 18, friendly_description: "Mounting the uni while pushing the uni forward, by placing one foot on the rear pedal and going up and over the wheel, without the wheel pausing, stopping or going backwards and continue riding forward, mounting directly into one foot riding.", skill_speed: 3, skill_before: nil, skill_after: 140},
    { number: 302, letter: "c", extra_description_number: 18, friendly_description: "Mounting the uni while pushing the uni forward, by placing one foot on the rear pedal and going up and over the wheel, without the wheel pausing, stopping or going backwards and continue riding forward, mounting directly into one foot extended riding.", skill_speed: 3, skill_before: nil, skill_after: 141},
    { number: 302, letter: "d", extra_description_number: 20, friendly_description: "Mounting the uni while pushing the uni forward, by placing one foot on the rear pedal and going up and over the wheel, without the wheel pausing, stopping or going backwards and continue riding forward, mounting directly into gliding without touching either of the pedals.", skill_speed: 3, skill_before: nil, skill_after: 155},
    { number: 302, letter: "e", extra_description_number: 21, friendly_description: "Mounting the uni while pushing the uni forward, by placing one foot on the rear pedal and going up and over the wheel, without the wheel pausing, stopping or going backwards and continue riding forward, mounting directly into coasting without touching either of the pedals.", skill_speed: 3, skill_before: nil, skill_after: 157},
    { number: 303, letter: "a", extra_description_number: 17, friendly_description: "Mounting the uni from standing in front of it, by placing one foot on the front pedal and going up and over the wheel or rotating the wheel forward to obtain balance.", skill_speed: 3, skill_before: nil, skill_after: 101},
    { number: 303, letter: "b", extra_description_number: 16, friendly_description: "Mounting the uni from standing in front of it, by placing one foot on the front pedal and going up and over the wheel or rotating the wheel forward to obtain balance, mounting to idling without riding.", skill_speed: 2, skill_before: nil, skill_after: 102},
    { number: 303, letter: "c", extra_description_number: 16, friendly_description: "Mounting the uni from standing in front of it, by placing one foot on the front pedal and going up and over the wheel or rotating the wheel forward to obtain balance, mounting into idling with only one foot on pedal.", skill_speed: 2, skill_before: nil, skill_after: 144},
    { number: 303, letter: "d", extra_description_number: 16, friendly_description: "Mounting the uni from standing in front of it, by placing one foot on the front pedal and going up and over the wheel or rotating the wheel forward to obtain balance, mounting into idling with only one foot on pedal the free leg is extended.", skill_speed: 2, skill_before: nil, skill_after: 145},
    { number: 303, letter: "e", extra_description_number: 15, friendly_description: "Mounting the uni from standing in front of it, by placing one foot on the front pedal, then putting the second foot onto the wheel, and going immediately into wheel walk.", skill_speed: 2, skill_before: nil, skill_after: 149},
    { number: 303, letter: "f", extra_description_number: 15, friendly_description: "Mounting the uni from standing in front of it, by placing one foot on the front pedal, then putting the second foot onto the wheel, and going immediately into wheel walk one foot.", skill_speed: 2, skill_before: nil, skill_after: 150},
    { number: 303, letter: "g", extra_description_number: 15, friendly_description: "Mounting the uni from standing in front of it, by placing one foot on the front pedal, then putting the second foot onto the wheel, and going immediately into wheel walk one foot extended.", skill_speed: 2, skill_before: nil, skill_after: 151},
    { number: 303, letter: "h", extra_description_number: 15, friendly_description: "Mounting the uni from standing in front of it, by placing one foot on the front pedal, then putting the second foot onto the wheel, and going immediately into stand up wheel walk.", skill_speed: 2, skill_before: nil, skill_after: 153},
    { number: 304, letter: "a", extra_description_number: 40, friendly_description: "Mounting the uni from standing behind it, placing one foot on the rear pedal and the abdomen on the seat, and going up and over the wheel or rotating the wheel backward to obtain balance. One hand holds onto the seat.", skill_speed: 3, skill_before: nil, skill_after: 135},
    { number: 304, letter: "b", extra_description_number: 7, friendly_description: "Mounting the uni from standing behind it, placing one foot on the rear pedal and the abdomen on the seat, and going up and over the wheel or rotating the wheel backward to obtain balance.", skill_speed: 3, skill_before: nil, skill_after: 136},
    { number: 304, letter: "c", extra_description_number: 35, friendly_description: "Mounting the uni from standing behind it, placing one foot on the rear pedal, holding the seat in front of the rider, and going up and over the wheel or rotating the wheel backward to obtain balance. The seat or hand holding the seat may rest against the rider.", skill_speed: 3, skill_before: nil, skill_after: 106},
    { number: 304, letter: "d", extra_description_number: 5, friendly_description: "Mounting the uni from standing behind it, placing one foot on the rear pedal, holding the seat in front of the rider, and going up and over the wheel or rotating the wheel backward to obtain balance.", skill_speed: 3, skill_before: nil, skill_after: 109},
    { number: 305, letter: "a", extra_description_number: nil, friendly_description: "Mounting the uni from standing next to it, by placing corresponding foot on pedal closest to rider, swinging the other leg around in front of the seat, getting seated and placing second foot on pedal.", skill_speed: 3, skill_before: nil, skill_after: 104},
    { number: 305, letter: "b", extra_description_number: nil, friendly_description: "Mounting the uni from standing next to it, by placing corresponding foot on pedal closest to rider, swinging the other leg around in front of the seat, getting seated and placing second foot on pedal. The leg goes once around the seat before the second foot is placed on the pedal.", skill_speed: 3, skill_before: nil, skill_after: 104},
    { number: 305, letter: "c", extra_description_number: nil, friendly_description: "Mounting the uni from standing next to it, by placing corresponding foot on pedal closest to rider, swinging the other leg around in front of the seat, getting seated and placing second foot on pedal. The leg goes twice around the seat before the second foot is placed on the pedal.", skill_speed: 3, skill_before: nil, skill_after: 104},
    { number: 305, letter: "d", extra_description_number: nil, friendly_description: "Mounting the uni from standing next to it, by placing corresponding foot on pedal closest to rider, swinging the other leg around in front of the seat, getting seated and placing second foot on pedal. The leg goes once around the seat before the second foot is placed on the pedal. The rider mounts the unicycle by laying the unicycle down on its side with one pedal touching the floor, one hand holding the seat and placing corresponding foot on pedal closest to rider and the other foot on the edge of the tire, neither foot may touch the floor, and mounts into the side mount.", skill_speed: 3, skill_before: nil, skill_after: 104},
    { number: 305, letter: "e", extra_description_number: nil, friendly_description: "Mounting the uni from standing next to it, by placing corresponding foot on pedal closest to rider, swinging the other leg around in front of the seat, getting seated and placing second foot on pedal. The leg goes twice around the seat before the second foot is placed on the pedal. The rider mounts the unicycle by laying the unicycle down on its side with one pedal touching the floor, one hand holding the seat and placing corresponding foot on pedal closest to rider and the other foot on the edge of the tire, neither foot may touch the floor, and mounts into the side mount.", skill_speed: 3, skill_before: nil, skill_after: 104},
    { number: 306, letter: "a", extra_description_number: nil, friendly_description: "Mounting the uni from standing next to it, by placing corresponding foot on pedal closest to rider, swinging the other leg around behind the seat, getting seated and placing second foot on pedal.", skill_speed: 3, skill_before: nil, skill_after: 104},
    { number: 306, letter: "b", extra_description_number: nil, friendly_description: "Mounting the uni from standing next to it, by placing corresponding foot on pedal closest to rider, swinging the other leg around behind the seat, getting seated and placing second foot on pedal. The leg goes once around the seat before the second foot is placed on the pedal.", skill_speed: 3, skill_before: nil, skill_after: 104},
    { number: 306, letter: "c", extra_description_number: nil, friendly_description: "Mounting the uni from standing next to it, by placing corresponding foot on pedal closest to rider, swinging the other leg around behind the seat, getting seated and placing second foot on pedal. The leg goes twice around the seat before the second foot is placed on the pedal.", skill_speed: 3, skill_before: nil, skill_after: 104},
    { number: 306, letter: "d", extra_description_number: nil, friendly_description: "Mounting the uni from standing next to it, by placing corresponding foot on pedal closest to rider, swinging the other leg around behind the seat, getting seated and placing second foot on pedal. The leg goes once around the seat before the second foot is placed on the pedal. The rider mounts the unicycle by laying the unicycle down on its side with one pedal touching the floor, one hand holding the seat and placing corresponding foot on pedal closest to rider and the other foot on the edge of the tire, neither foot may touch the floor, and mounts into the side mount.", skill_speed: 3, skill_before: nil, skill_after: 104},
    { number: 306, letter: "e", extra_description_number: nil, friendly_description: "Mounting the uni from standing next to it, by placing corresponding foot on pedal closest to rider, swinging the other leg around behind the seat, getting seated and placing second foot on pedal. The leg goes twice around the seat before the second foot is placed on the pedal. The rider mounts the unicycle by laying the unicycle down on its side with one pedal touching the floor, one hand holding the seat and placing corresponding foot on pedal closest to rider and the other foot on the edge of the tire, neither foot may touch the floor, and mounts into the side mount.", skill_speed: 3, skill_before: nil, skill_after: 104},
    { number: 307, letter: "a", extra_description_number: nil, friendly_description: "Mounting the uni from standing behind it, by jumping on it, landing on both pedals simultaneously. The unicycle frame is upright (perpendicular to the floor) before the mount.", skill_speed: 3, skill_before: nil, skill_after: 104},
    { number: 307, letter: "b", extra_description_number: nil, friendly_description: "Mounting the uni from standing behind it, by jumping on it, landing on both pedals simultaneously. The rider lets go of the uni before his or her feet leave the floor. The unicycle frame is upright (perpendicular to the floor) before the mount.", skill_speed: 3, skill_before: nil, skill_after: 104},
    { number: 307, letter: "c", extra_description_number: 19, friendly_description: "Mounting the uni from standing behind it, by jumping on it, landing on both pedals simultaneously. The rider lands with the seat in front, not touching body The unicycle frame is upright (perpendicular to the floor) before the mount.", skill_speed: 3, skill_before: nil, skill_after: 109},
    { number: 307, letter: "d", extra_description_number: 19, friendly_description: "Mounting the uni from standing behind it, by jumping on it, landing on both pedals simultaneously. The rider lands with seat in back not touching body. The unicycle frame is upright (perpendicular to the floor) before the mount.", skill_speed: 3, skill_before: nil, skill_after: 125},
    { number: 307, letter: "e", extra_description_number: 15, friendly_description: "Mounting the uni from standing behind it, by jumping over the seat, landing in wheel walk position. The unicycle frame is upright (perpendicular to the floor) before the mount.", skill_speed: 2, skill_before: nil, skill_after: 149},
    { number: 307, letter: "f", extra_description_number: nil, friendly_description: "Mounting the uni from standing behind it, by jumping on it, landing on both pedals simultaneously. The unicycle is lying on its side. Rider stands on the side of the tire with neither foot touching the floor, then jumps up, pulls saddle into position, and lands on saddle and pedals.", skill_speed: 3, skill_before: nil, skill_after: 104},
    { number: 307, letter: "g", extra_description_number: nil, friendly_description: "Mounting the uni from standing behind it, by jumping on it, landing on both pedals simultaneously. The uni or rider gets spun 180  degrees around a vertical axis after the rider leaves the floor but before the rider lands on it. The unicycle frame is upright (perpendicular to the floor) before the mount.", skill_speed: 3, skill_before: nil, skill_after: 104},
    { number: 307, letter: "h", extra_description_number: nil, friendly_description: "Mounting the uni from standing behind it, by jumping on it, landing on both pedals simultaneously. The uni or rider gets spun 360 degrees around a vertical axis after the rider leaves the floor but before the rider lands on it. The unicycle frame is upright (perpendicular to the floor) before the mount.", skill_speed: 3, skill_before: nil, skill_after: 104},
    { number: 307, letter: "i", extra_description_number: nil, friendly_description: "Mounting the uni from standing behind it, by jumping on it, landing on both pedals simultaneously. The rider turns around 180 degrees before landing on the unicycle. The unicycle frame is upright (perpendicular to the floor) before the mount.", skill_speed: 3, skill_before: nil, skill_after: 104},
    { number: 307, letter: "j", extra_description_number: 15, friendly_description: "Mounting the uni from standing behind it, by jumping on it, landing in stand up wheel walk position. The unicycle frame is upright (perpendicular to the floor) before the mount.", skill_speed: 2, skill_before: nil, skill_after: 153},
    { number: 307, letter: "k", extra_description_number: 31, friendly_description: "Mounting the uni from standing behind it, letting go of the seat before leaving the floor, and jumping on it, landing on both pedals simultaneously. The rider lands in seat drag in front position.", skill_speed: 3, skill_before: nil, skill_after: 137},
    { number: 307, letter: "l", extra_description_number: 31, friendly_description: "Mounting the uni with the unicycle on the floor in seat drag in front position and the wheel is held upright with the legs before jumping and landing on both pedals simultaneously. The rider lands in seat drag in front position.", skill_speed: 3, skill_before: nil, skill_after: 137},
    { number: 307, letter: "m", extra_description_number: 30, friendly_description: "Mounting the uni with the unicycle on the floor in seat drag in back position and the wheel is held upright with the legs before jumping and landing on both pedals simultaneously. The rider lands in seat drag in back position.", skill_speed: 3, skill_before: nil, skill_after: 138},
    { number: 307, letter: "n", extra_description_number: 30, friendly_description: "Mounting the uni with the unicycle on the floor in seat drag in back position and is held upright with the feet touching the seat before jumping and landing on both pedals simultaneously. The rider lands in seat drag in back position.", skill_speed: 3, skill_before: nil, skill_after: 138},
    { number: 308, letter: "a", extra_description_number: nil, friendly_description: "Mounting the uni from standing next to it, by jumping on it with on leg going around the front of the seat and landing on both pedals simultaneously.", skill_speed: 3, skill_before: nil, skill_after: 101},
    { number: 308, letter: "b", extra_description_number: nil, friendly_description: "Mounting the uni from standing next to it, by jumping on it with on leg going around the front of the seat and landing on both pedals simultaneously. The rider lets go of the uni before his or her feet leave the floor.", skill_speed: 3, skill_before: nil, skill_after: 101},
    { number: 308, letter: "c", extra_description_number: nil, friendly_description: "Mounting the uni from standing next to it, by jumping on it with on leg going around the front of the seat and landing on both pedals simultaneously. Into riding seat on side, seat touching body. ", skill_speed: 3, skill_before: nil, skill_after: 133},
    { number: 308, letter: "d", extra_description_number: 15, friendly_description: "Mounting the uni from standing next to it, by jumping on it with on leg going around the front of the seat and landing on it. The feet are placed on the wheel, without touching the pedals, and the rider goes immediately into wheel walk.", skill_speed: 2, skill_before: nil, skill_after: 149},
    { number: 308, letter: "e", extra_description_number: 15, friendly_description: "Mounting the uni from standing next to it, by jumping on it with on leg going around the front of the seat and landing on it. The foot is placed on the wheel, without touching the pedals, and the rider goes immediately into wheel walk one foot.", skill_speed: 2, skill_before: nil, skill_after: 150},
    { number: 308, letter: "f", extra_description_number: 15, friendly_description: "Mounting the uni from standing next to it, by jumping on it with on leg going around the front of the seat and landing on it. The foot is placed on the wheel, without touching the pedals, and the rider goes immediately into wheel walk one foot with the free leg extended.", skill_speed: 2, skill_before: nil, skill_after: 151},
    { number: 308, letter: "g", extra_description_number: nil, friendly_description: "Mounting the uni from standing next to it, by jumping on it with on leg going around the front of the seat and landing on both pedals simultaneously. The uni gets spun 180 degrees around a vertical axis after the rider leaves the floor but before the rider lands on it.", skill_speed: 3, skill_before: nil, skill_after: 104},
    { number: 308, letter: "h", extra_description_number: nil, friendly_description: "Mounting the uni from standing next to it, by jumping on it with on leg going around the front of the seat and landing on both pedals simultaneously. The uni gets spun 360 degrees around a vertical axis after the rider leaves the floor but before the rider lands on it.", skill_speed: 3, skill_before: nil, skill_after: 104},
    { number: 308, letter: "i", extra_description_number: 20, friendly_description: "Mounting the uni by pushing the uni forward, jump on it without touching the pedals and go immediately into gliding.", skill_speed: 3, skill_before: nil, skill_after: 155},
    { number: 309, letter: "a", extra_description_number: 11, friendly_description: "Mounting the unicycle and without pausing or idling, spinning 360 degrees around a vertical axis.", skill_speed: 3, skill_before: nil, skill_after: 101},
    { number: 309, letter: "b", extra_description_number: 11, friendly_description: "Mounting the unicycle and without pausing or idling, spinning 720 degrees around a vertical axis.", skill_speed: 3, skill_before: nil, skill_after: 101},
    { number: 310, letter: "a", extra_description_number: nil, friendly_description: "Mounting the uni from standing over it (the unicycle lying on the floor) by placing corresponding foot on pedal, kicking the seat up into place with the other foot without either hand touching the seat and placing the second foot on the pedal. One hand may touch the seat", skill_speed: 3, skill_before: nil, skill_after: 104},
    { number: 310, letter: "b", extra_description_number: nil, friendly_description: "Mounting the uni from standing over it (the unicycle lying on the floor) by placing corresponding foot on pedal, kicking the seat up into place with the other foot without either hand touching the seat and placing the second foot on the pedal.", skill_speed: 3, skill_before: nil, skill_after: 104},
    { number: 310, letter: "c", extra_description_number: 15, friendly_description: "Mounting the uni from standing over it (the unicycle lying on the floor) by placing corresponding foot on pedal, kicking the seat up into place with the other foot without either hand touching the seat and placing the second foot on the pedal. The second foot is placed on the wheel instead of on the pedal and the rider goes immediately into wheel walk.", skill_speed: 3, skill_before: nil, skill_after: 149},
    { number: 310, letter: "d", extra_description_number: 15, friendly_description: "Mounting the uni from standing over it (the unicycle lying on the floor) by placing corresponding foot on pedal, kicking the seat up into place with the other foot without either hand touching the seat and placing the second foot on the pedal. The second foot is placed on the wheel instead of on the pedal and the rider goes immediately into wheel walk one foot.", skill_speed: 3, skill_before: nil, skill_after: 150},
    { number: 310, letter: "e", extra_description_number: 15, friendly_description: "Mounting the uni from standing over it (the unicycle lying on the floor) by placing corresponding foot on pedal, kicking the seat up into place with the other foot without either hand touching the seat and placing the second foot on the pedal. The second foot is placed on the wheel instead of on the pedal and the rider goes immediately into wheel walk one foot with the free leg extended.", skill_speed: 3, skill_before: nil, skill_after: 151},
    { number: 311, letter: "a", extra_description_number: nil, friendly_description: "Mounting the unicycle from standing behind it (wheel upright with seat on the floor) by jumping onto the pedals, picking up the seat and getting seated.", skill_speed: 3, skill_before: nil, skill_after: 101},
    { number: 312, letter: "a", extra_description_number: nil, friendly_description: "Mounting the unicycle from standing behind it (wheel upright; seat on floor in seat drag in front position) by placing corresponding foot on the pedal, swinging the frame upright with the second foot. The seat is grabbed with a hand, into seat in front idling or hopping with the seat touching the body.", skill_speed: 3, skill_before: nil, skill_after: 116},
    { number: 312, letter: "b", extra_description_number: nil, friendly_description: "Mounting the unicycle from standing beside it (wheel upright; seat on floor in seat drag in back position) by placing corresponding foot on the pedal, lifting the frame upright with the second foot on the same side of the unicycle. The second leg swings around the back of the seat before getting seated and placing the second foot on the pedal, without touching the seat with the hand.", skill_speed: 3, skill_before: nil, skill_after: 101},
    { number: 313, letter: "a", extra_description_number: nil, friendly_description: "Mounting the unicycle starting with rider laying face down on the floor. The uni is in the riding position but with only the seat and wheel touching the floor. The rider pushes up using only the hands, the feet can only touch the pedals, into the riding position.", skill_speed: 3, skill_before: nil, skill_after: 101}
  ]

  extra_des_data = [
    { id: 1, description: "5 cycles"},
    { id: 2, description: "3 seconds"},
    { id: 3, description: "5 twists"},
    { id: 4, description: "3 rotations"},
    { id: 5, description: "not touching body"},
    { id: 6, description: "5 hops"},
    { id: 7, description: "hands not touching seat"},
    { id: 8, description: "one foot each side"},
    { id: 9, description: "5 hops and not touch with other foot"},
    { id: 10, description: "seat may touch body"},
    { id: 11, description: "not less"},
    { id: 12, description: "hand holding seat"},
    { id: 13, description: "with hand"},
    { id: 14, description: "after jumping"},
    { id: 15, description: "ww at least one rev"},
    { id: 16, description: "not less than 2 1/2 idles"},
    { id: 17, description: "ride at least one rev"},
    { id: 18, description: "ride one ft at least one rev"},
    { id: 19, description: "ride seat out at least one rev"},
    { id: 20, description: "glide at least one rev"},
    { id: 21, description: "coast at least one rev"},
    { id: 22, description: "not less than 2 1/2 hops"},
    { id: 23, description: "side ride at least one rev"},
    { id: 24, description: "5 twists"},
    { id: 25, description: "hands and body not touching seat"},
    { id: 26, description: "5 cycles and seat not touching body"},
    { id: 27, description: "5 hops and seat not touching body"},
    { id: 28, description: "jump up; ww at least one rev"},
    { id: 29, description: "free leg(s) straight and toe(s) pointed"},
    { id: 30, description: "ride seat drag in back at least one rev"},
    { id: 31, description: "ride seat drag in front at least one rev"},
    { id: 32, description: "3 rotations and seat not touching body"},
    { id: 33, description: "toe pointed"},
    { id: 34, description: "5 cycles and toe pointed"},
    { id: 35, description: "one hand"},
    { id: 36, description: "free leg straight & toe pointed; seat not touching"},
    { id: 37, description: "ride at least one rev or not less than 2.5 idles"},
    { id: 38, description: "ride at least one rev/not less than 2.5 idles/hops"},
    { id: 39, description: "ride at least one rev or not less than 2.5 hops"},
    { id: 40, description: "ride stomach on seat at least one rev"},
    { id: 41, description: "ride seat in back or on side at least one rev"},
    { id: 42, description: "ride seat in back at least one rev"},
    { id: 43, description: "5 hops, only 1 hand"},
    { id: 44, description: "5 hops, seat not touching body, only 1 hand"}
  ]

  before_after_skill_data = [
    { id: 101, description: "riding"},
    { id: 102, description: "idling"},
    { id: 103, description: "riding or idling"},
    { id: 104, description: "riding or hopping or idling"},
    { id: 105, description: "riding bwd"},
    { id: 106, description: "seat in front - riding, touching"},
    { id: 107, description: "seat in front - riding, touching for final 1 rev, 1 hop/idle"},
    { id: 108, description: "seat in front - riding, not touching after 1 rev, 1 hop/idle"},
    { id: 109, description: "seat in front - riding, not touching"},
    { id: 110, description: "seat in front - riding or hopping, touching"},
    { id: 111, description: "seat in front - riding or hopping, not touching"},
    { id: 112, description: "seat in front - riding or idling or hopping, touching"},
    { id: 113, description: "seat in front - riding or idling or hopping, not touching"},
    { id: 114, description: "seat in front - idling, touching"},
    { id: 115, description: "seat in front - idling, not touching"},
    { id: 116, description: "seat in front - idling or hopping, touching"},
    { id: 117, description: "seat in front - idling or hopping, not touching"},
    { id: 118, description: "seat in front - hopping, touching"},
    { id: 119, description: "seat in front - hopping, not touching"},
    { id: 120, description: "seat in front - riding bwd, touching"},
    { id: 121, description: "seat in front - riding bwd, not touching"},
    { id: 122, description: "seat in back - riding, touching"},
    { id: 123, description: "seat in back - riding, touching for final 1 rev, 1 hop/idle"},
    { id: 124, description: "seat in back - riding, not touching after 1 rev, 1 hop/idle"},
    { id: 125, description: "seat in back - riding, not touching"},
    { id: 126, description: "seat in back - idling, touching"},
    { id: 127, description: "seat in back - idling, not touching"},
    { id: 128, description: "seat in back - hopping, touching"},
    { id: 129, description: "seat in back - hopping, not touching"},
    { id: 130, description: "seat in back - riding bwd, touching"},
    { id: 131, description: "seat in back - riding bwd, not touching"},
    { id: 132, description: "seat in back or seat on side, touching"},
    { id: 133, description: "seat on side - riding, touching"},
    { id: 134, description: "seat on side - riding, not touching"},
    { id: 135, description: "stomach on seat - riding, 1 hand"},
    { id: 136, description: "stomach on seat - riding"},
    { id: 137, description: "seat drag in front"},
    { id: 138, description: "seat drag in back"},
    { id: 139, description: "riding or seat in front - riding, touching"},
    { id: 140, description: "1ft - riding"},
    { id: 141, description: "1ft ext - riding"},
    { id: 142, description: "1ft - riding bwd"},
    { id: 143, description: "1ft ext - riding bwd"},
    { id: 144, description: "1ft - idle"},
    { id: 145, description: "1ft ext - idle"},
    { id: 146, description: "crossover"},
    { id: 147, description: "crossover bwd"},
    { id: 148, description: "side ride"},
    { id: 149, description: "wheel walk"},
    { id: 150, description: "wheel walk 1ft"},
    { id: 151, description: "wheel walk 1ft ext"},
    { id: 152, description: "sideways ww"},
    { id: 153, description: "stand up ww"},
    { id: 154, description: "stand up koosh koosh"},
    { id: 155, description: "gliding or gliding, foot on frame"},
    { id: 156, description: "gliding bwd"},
    { id: 157, description: "coasting"},
    { id: 158, description: "stand up glide or stand up glide, foot on frame"},
    { id: 159, description: "stand up glide bwd, or stand up glide bwd, foot on frame"},
    { id: 160, description: "crank idling"},
    { id: 161, description: "hopping"},
    { id: 162, description: "hopping on wheel"},
    { id: 163, description: "stand up hopping on wheel freehanded"},
    { id: 164, description: "stillstand"},
    { id: 165, description: "seat in front - 1ft idling, touching"},
    { id: 166, description: "seat on side - idling, touching"},
    { id: 167, description: "seat in back - riding or idling or hopping, touching"},
    { id: 168, description: "seat on side - riding or idling or hopping, touching"},
    { id: 169, description: "side hopping or side hopping, foot touching tire"}
  ]

  def process_skill_data_row(skill_data, extra_des_data, before_after_skill_data)
    additional_description_id =
      if skill_data[:extra_description_number].present?
        extra_description = extra_des_data.detect { |entry| entry[:id] == skill_data[:extra_description_number] }
        StandardSkillEntryAdditionalDescription.find_or_create_by(description: extra_description[:description]).id
      end

    skill_speed_description =
      case skill_data[:skill_speed]
      when 1
        "Slow"
      when 2
        "Medium"
      when 3
        "Fast"
      end

    skill_before_id =
      if skill_data[:skill_before].present?
        skill_before_description = before_after_skill_data.detect { |entry| entry[:id] == skill_data[:skill_before] }
        StandardSkillEntryTransition.find_or_create_by(description: skill_before_description[:description]).id
      end

    skill_after_id =
      if skill_data[:skill_after].present?
        skill_after_description = before_after_skill_data.detect { |entry| entry[:id] == skill_data[:skill_after] }
        StandardSkillEntryTransition.find_or_create_by(description: skill_after_description[:description]).id
      end

    standard_skill_entry = StandardSkillEntry.find_by(number: skill_data[:number], letter: skill_data[:letter])

    standard_skill_entry.update_attributes(
      friendly_description: skill_data[:friendly_description],
      additional_description_id: additional_description_id,
      skill_speed: skill_speed_description,
      skill_before_id: skill_before_id,
      skill_after_id: skill_after_id)
  end

  skill_data.each do |skill_data_row|
    process_skill_data_row(skill_data_row, extra_des_data, before_after_skill_data)
  end
end
# StandardSkill 1 = slow, 2 = medium, 3 = fast
