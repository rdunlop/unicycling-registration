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
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  event_class                  :string(255)
#  boundary_calculation_enabled :boolean
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
    jt.valid?.should == true
  end

  it "destroys the judge when it is destroyed" do
    judge = FactoryGirl.create(:judge)
    jt = judge.judge_type

    Judge.count.should == 1

    jt.destroy

    Judge.count.should == 0
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
    jt.valid?.should == false
    jt.val_1_max = 15
    jt.valid?.should == true
  end
  it "require event_class" do
    jt = FactoryGirl.build(:judge_type)
    ec = jt.event_class
    jt.event_class = nil
    jt.valid?.should == false
    jt.event_class = ec
    jt.valid?.should == true
  end
  it "allows boundary_calculation_enabled" do
    jt = FactoryGirl.build(:judge_type)
    jt.boundary_calculation_enabled = true
    jt.valid?.should == true
  end
end
