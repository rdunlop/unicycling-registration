require 'spec_helper'

describe TwoAttemptEntry do

  describe "building array from ImportResults" do
    let(:user) { FactoryGirl.create(:user) }
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
end
