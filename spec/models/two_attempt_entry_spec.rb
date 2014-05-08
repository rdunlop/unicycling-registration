require 'spec_helper'

describe TwoAttemptEntry do

  describe "building array from ImportResults" do
    let(:user) { FactoryGirl.create(:user) }
    let(:bib_number1) { 1123 }
    let(:bib_number2) { 111 }
    let(:competition) { FactoryGirl.create(:competition) }

    before :each do
      i1a = FactoryGirl.create(:import_result, user: user, competition: competition, bib_number: bib_number1)
      i1b = FactoryGirl.create(:import_result, user: user, competition: competition, bib_number: bib_number1)
      i2a = FactoryGirl.create(:import_result, user: user, competition: competition, bib_number: bib_number2)
      i2b = FactoryGirl.create(:import_result, user: user, competition: competition, bib_number: bib_number2)
    end

    it "can create an array" do
      entries = TwoAttemptEntry.entries_for(user, competition)
      expect(entries.length).to eq(2)
      expect(entries.map(&:bib_number)).to match_array([bib_number1, bib_number2])
    end
  end
end
