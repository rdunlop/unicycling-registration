# == Schema Information
#
# Table name: import_results
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  raw_data            :string(255)
#  bib_number          :integer
#  minutes             :integer
#  seconds             :integer
#  thousands           :integer
#  created_at          :datetime
#  updated_at          :datetime
#  competition_id      :integer
#  points              :decimal(6, 3)
#  details             :string(255)
#  is_start_time       :boolean          default(FALSE)
#  number_of_laps      :integer
#  status              :string(255)
#  comments            :text
#  comments_by         :string(255)
#  heat                :integer
#  lane                :integer
#  number_of_penalties :integer
#
# Indexes
#
#  index_import_results_on_user_id  (user_id)
#  index_imported_results_user_id   (user_id)
#

require 'spec_helper'

describe ImportResult do
  before(:each) do
    @ir = FactoryGirl.build_stubbed(:import_result)
  end
  it "has a valid factory" do
    expect(@ir.valid?).to eq(true)
  end

  it "requires a user" do
    @ir.user_id = nil
    expect(@ir.valid?).to eq(false)
  end

  it "requires a competition" do
    @ir.competition_id = nil
    expect(@ir.valid?).to eq(false)
  end

  it "automatically sets the details if none are specified" do
    @ir.points = 5
    @ir.details = ""
    expect(@ir).to be_valid
    expect(@ir.details).to eq("5.0pts")
  end
end

describe "when importing the result" do
  describe "with a competition and competitor in multiple competitions" do
    before :each do
      @event = FactoryGirl.create(:event)
      @competition1 = FactoryGirl.create(:timed_competition, event: @event)
      @competition2 = FactoryGirl.create(:timed_competition, event: @event)
      @competitor1 = FactoryGirl.create(:event_competitor, competition: @competition1)
      @competitor2 = FactoryGirl.create(:event_competitor, competition: @competition2)
      @comp = FactoryGirl.create(:competitor, bib_number: 100)
      @competitor1.members.create(registrant: @comp)
      @competitor2.members.create(registrant: @comp)
    end

    it "assigns the import_result to the correct competition" do
      ir = FactoryGirl.create(:import_result, bib_number: 100, competition: @competition2)
      ir.import!
      expect(TimeResult.last.competition).to eq(@competition2)
    end
  end
end
