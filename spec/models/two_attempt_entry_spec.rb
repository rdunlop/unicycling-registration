require 'spec_helper'

describe TwoAttemptEntry do
  let(:competition) { FactoryGirl.create(:competition) }
  let(:competitor1) { FactoryGirl.create(:event_competitor, competition: competition) }
  let(:user) { FactoryGirl.create(:user) }

  describe "creating time_results from TwoAttemptEntry" do
    let(:two_attempt_entry) { TwoAttemptEntry.new(
      user: user,
      bib_number: competitor1.bib_number,
      competition: competition,

      minutes_1: 1,
      seconds_1: 2,
      thousands_1: 3,
      status_1: nil,

      minutes_2: 4,
      seconds_2: 5,
      thousands_2: 6,
      status_2: "DQ"
      ) }
    it "can save to the database" do
      expect(two_attempt_entry.save).to eq(true)
    end

    it "can import the results to time results" do
      expect { two_attempt_entry.import! }.to change(TimeResult, :count).by(2)
    end
  end
end
