require 'spec_helper'

describe TwoAttemptEntry do
  let(:competition) { FactoryGirl.create(:competition) }
  let(:competitor1) { FactoryGirl.create(:event_competitor, competition: competition) }
  let(:competitor2) { FactoryGirl.create(:event_competitor, competition: competition) }
  let(:user) { FactoryGirl.create(:user) }

  describe "building array from ImportResults" do
    let(:is_start_time) { true }
    let(:bib_number1) { 1123 }
    let(:bib_number2) { 111 }
    let(:competition) { FactoryGirl.create(:competition) }

    before :each do
      i1a = FactoryGirl.create(:import_result, user: user, competition: competition, bib_number: bib_number1, is_start_time: is_start_time)
      i1b = FactoryGirl.create(:import_result, user: user, competition: competition, bib_number: bib_number1, is_start_time: is_start_time)
      i2a = FactoryGirl.create(:import_result, user: user, competition: competition, bib_number: bib_number2, is_start_time: is_start_time)
      i2b = FactoryGirl.create(:import_result, user: user, competition: competition, bib_number: bib_number2, is_start_time: is_start_time)
    end

    it "can create an array" do
      entries = TwoAttemptEntry.entries_for(user, competition, is_start_time)
      expect(entries.length).to eq(2)
      expect(entries.map(&:bib_number)).to match_array([bib_number1, bib_number2])
    end
  end

  describe "disqualified numerics" do
    it "converts 1 to true" do
      expect(TwoAttemptEntry.new(dq_1: "1").dq_1).to be_truthy
      expect(TwoAttemptEntry.new(dq_2: "1").dq_2).to be_truthy
    end

    it "converts 0 to false" do
      expect(TwoAttemptEntry.new(dq_1: "0").dq_1).to be_falsy
      expect(TwoAttemptEntry.new(dq_2: "0").dq_2).to be_falsy
    end
  end

  describe "creating time_results from TwoAttemptEntry" do
    let(:two_attempt_entry) { TwoAttemptEntry.new(
      user: user,
      bib_number: competitor1.bib_number,
      competition: competition,

      minutes_1: 1,
      seconds_1: 2,
      thousands_1: 3,
      dq_1: false,

      minutes_2: 4,
      seconds_2: 5,
      thousands_2: 6,
      dq_2: true
      ) }
    it "can save to the database" do
      expect(two_attempt_entry.save).to eq(true)
      expect(ImportResult.count).to eq(2)
    end
  end
end
