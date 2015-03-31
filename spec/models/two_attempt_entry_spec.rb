require 'spec_helper'

describe TwoAttemptEntry do
  let(:competition) { FactoryGirl.create(:competition) }
  let(:competitor1) { FactoryGirl.create(:event_competitor, competition: competition) }
  let(:user) { FactoryGirl.create(:user) }

  describe "creating time_results from TwoAttemptEntry" do
    let(:two_attempt_entry) { 
      TwoAttemptEntry.new(
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
      )
    }
    it "can save to the database" do
      expect(two_attempt_entry.save).to eq(true)
    end

    it "can import the results to time results" do
      expect { two_attempt_entry.import! }.to change(TimeResult, :count).by(2)
    end
  end
end

# == Schema Information
#
# Table name: two_attempt_entries
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  competition_id :integer
#  bib_number     :integer
#  minutes_1      :integer
#  minutes_2      :integer
#  seconds_1      :integer
#  status_1       :string(255)
#  seconds_2      :integer
#  thousands_1    :integer
#  thousands_2    :integer
#  status_2       :string(255)
#  is_start_time  :boolean          default(FALSE), not null
#  created_at     :datetime
#  updated_at     :datetime
#
