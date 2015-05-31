# == Schema Information
#
# Table name: judge_types
#
#  id                           :integer          not null, primary key
#  name                         :string(255)
#  val_1_description            :string(255)
#  val_2_description            :string(255)
#  val_3_description            :string(255)
#  val_4_description            :string(255)
#  val_1_max                    :integer
#  val_2_max                    :integer
#  val_3_max                    :integer
#  val_4_max                    :integer
#  created_at                   :datetime
#  updated_at                   :datetime
#  event_class                  :string(255)
#  boundary_calculation_enabled :boolean          default(FALSE), not null
#
# Indexes
#
#  index_judge_types_on_name_and_event_class  (name,event_class) UNIQUE
#

require 'spec_helper'

describe JudgeType do
  it "stores the 4 descriptions, as well as a name" do
    jt = JudgeType.new
    jt.val_1_description = "Mistakes"
    jt.val_2_description = "Cherography & Style"
    jt.val_3_description = "Originality of Performance & Showmanship"
    jt.val_4_description = "Interpretation"
    jt.name = "Presentation"
    jt.event_class = "Freestyle"
    jt.boundary_calculation_enabled = false
    expect(jt.valid?).to eq(true)
  end

  it "destroys the judge when it is destroyed" do
    judge = FactoryGirl.create(:judge)
    jt = judge.judge_type

    expect(Judge.count).to eq(1)

    jt.destroy

    expect(Judge.count).to eq(0)
  end
  it "requires limits to be specified" do
    jt = JudgeType.new
    jt.val_1_description = "Mistakes"
    jt.val_2_description = "Cherography & Style"
    jt.val_3_description = "Originality of Performance & Showmanship"
    jt.val_4_description = "Interpretation"
    jt.event_class = "Freestyle"
    jt.name = "Presentation"
    jt.val_1_max = nil
    jt.boundary_calculation_enabled = false
    expect(jt.valid?).to eq(false)
    jt.val_1_max = 15
    expect(jt.valid?).to eq(true)
  end
  it "require event_class" do
    jt = FactoryGirl.build(:judge_type)
    ec = jt.event_class
    jt.event_class = nil
    expect(jt.valid?).to eq(false)
    jt.event_class = ec
    expect(jt.valid?).to eq(true)
  end
  it "allows boundary_calculation_enabled" do
    jt = FactoryGirl.build(:judge_type)
    jt.boundary_calculation_enabled = true
    expect(jt.valid?).to eq(false) # XXX Boundary Scores are disabled
  end
end
