# == Schema Information
#
# Table name: scores
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  val_1         :decimal(5, 3)
#  val_2         :decimal(5, 3)
#  val_3         :decimal(5, 3)
#  val_4         :decimal(5, 3)
#  notes         :text
#  judge_id      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe Score do
  let(:judge) { FactoryGirl.build_stubbed(:judge) }
  let(:subject) { FactoryGirl.build_stubbed(:score, :val_1 => 10, :judge => judge) }

  describe "when calculating the placing points" do
    it { subject.new_calc_placing_points(1, 0).should == 1 }
    it { subject.new_calc_placing_points(1, 1).should == 1.5 }
    it { subject.new_calc_placing_points(2, 0).should == 2 }
    it { subject.new_calc_placing_points(2, 1).should == 2.5 }
    it { subject.new_calc_placing_points(2, 2).should == 3 }
  end

  describe "when the score is invalid" do
    before(:each) do
      allow(subject).to receive(:invalid?).and_return(true)
    end

    it "says that it has a judge_place of 0" do
      expect(subject.judged_place).to eq(0)
    end
  end

  describe "ties" do
    before :each do
      allow(subject).to receive(:ties).and_return(1)
      allow(subject).to receive(:judged_place).and_return(2)
    end
    it "calculates the placing points for this tie score" do
     expect(subject.placing_points).to eq(2.5)
    end
  end

  describe "with multiple scores" do
    before :each do
      allow(judge).to receive(:score_totals).and_return([0, 5, 10, 5])
    end

    describe "the lowest scoring competitor" do
      before :each do
        allow(subject).to receive(:total).and_return(0)
      end

      it "calculates the proper placement of each score" do
        expect(subject.judged_place).to eq(4)
      end

      it {
      expect(subject.ties).to eq(0)
      }

      it "has the lowest (after ties) placing points" do
        expect(subject.placing_points).to eq(4)
      end
    end

    describe "the highest scoring competitor" do
      before :each do
        allow(subject).to receive(:total).and_return(10)
      end

      it {
      expect(subject.judged_place).to eq(1)
      }

      it "has 1 placing point (highest)" do
        expect(subject.placing_points).to eq(1)
      end
    end
    describe "the tie in the middle" do
      before :each do
        allow(subject).to receive(:total).and_return(5)
      end

      it {
      expect(subject.judged_place).to eq(2)
      }

      it "has a tie" do
        expect(subject.ties).to eq(1)
      end

      it "splits the placing points" do
        expect(subject.placing_points).to eq(2.5)
      end
    end
  end

  describe "when calculating totals" do
    it "Must have a value above 0" do
      subject.val_1 = -1
      subject.val_2 = -1
      subject.valid?.should == false
    end

    it "should total the values to create the Total" do
      subject.val_1 = 1.0
      subject.val_2 = 2.0
      subject.val_3 = 3.0
      subject.val_4 = 4.0

      subject.total.should == 10
    end
  end
end

describe Score do
  before (:each) do
    @judge = FactoryGirl.create(:judge)
  end

  it "should not be able to have the same score/judge created twice" do
    score = FactoryGirl.create(:score)

    score2 = FactoryGirl.build(:score, :judge => score.judge, :competitor => score.competitor)

    score2.valid?.should == false
  end

  it "should store the judge" do
    score = Score.new
    score.val_1 = 1.0
    score.val_2 = 2.0
    score.val_3 = 3.0
    score.val_4 = 4.0
    score.valid?.should == false
    score.total.should == 0
    score.competitor_id = 4
    score.valid?.should == false
    score.judge = @judge
    score.valid?.should == true
  end
  it "should validate the bounds of the Values" do
    score = Score.new
    score.val_1 = 1.0
    score.val_2 = 2.0
    score.val_3 = 3.0
    score.val_4 = 4.0
    score.competitor_id = 4
    score.judge = @judge
    score.valid?.should == true
    score.val_1 = 11.0
    score.valid?.should == false
  end
  describe "when the score is based on a judge with judge_type" do
    before(:each) do
        @jt = FactoryGirl.create(:judge_type, :val_1_max => 5, :val_2_max => 6, :val_3_max => 7, :val_4_max => 20)
        @judge = FactoryGirl.create(:judge, :judge_type => @jt)
        @score = Score.new
        @score.val_1 = 1.0
        @score.val_2 = 2.0
        @score.val_3 = 3.0
        @score.val_4 = 4.0
        @score.competitor_id = 4
        @score.judge = @judge
    end
    it "Should validate the bounds of the values when the judge_type specifies different max" do
        score = @score

        score.valid?.should == true
        score.val_1 = 10.0
        score.valid?.should == false
        score.val_1 = 5.0
        score.valid?.should == true
    end
    it "should check each column separately for max" do
        score = @score
        score.valid?.should == true

        score.val_1 = 6.0
        score.valid?.should == false
        score.val_1 = 5.0
        score.valid?.should == true

        score.val_2 = 7.0
        score.valid?.should == false
        score.val_2 = 2.0
        score.valid?.should == true

        score.val_3 = 9.0
        score.valid?.should == false
        score.val_3 = 7.0
        score.valid?.should == true

        score.val_4 = 21.0
        score.valid?.should == false
        score.val_4 = 20.0
        score.valid?.should == true
    end
  end
end
