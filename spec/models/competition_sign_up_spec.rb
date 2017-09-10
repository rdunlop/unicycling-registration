require 'spec_helper'

describe CompetitionSignUp do
  let!(:event_configuration) { FactoryGirl.create(:event_configuration, start_date: Date.current) }
  let!(:young_registrant) { FactoryGirl.create(:registrant, :competitor, :minor, birthday: 5.years.ago) }
  let!(:middle_registrant) { FactoryGirl.create(:registrant, :competitor, :minor, birthday: 15.years.ago) }
  let!(:old_registrant) { FactoryGirl.create(:competitor, birthday: 36.years.ago) }

  let(:agt) { FactoryGirl.create(:age_group_type) }
  let(:young_description) { "young" }
  let(:middle_description) { "middle" }
  let(:old_description) { "old" }
  let!(:age_group_entry_1) { FactoryGirl.create(:age_group_entry, short_description: young_description, age_group_type: agt, start_age: 0, end_age: 9) }
  let!(:age_group_entry_2) { FactoryGirl.create(:age_group_entry, short_description: middle_description, age_group_type: agt, start_age: 10, end_age: 29) }
  let!(:age_group_entry_3) { FactoryGirl.create(:age_group_entry, short_description: old_description, age_group_type: agt, start_age: 30, end_age: 100) }
  let(:competition) { FactoryGirl.create(:competition, age_group_type: agt) }
  let(:competition_sign_up) { described_class.new(competition) }
  before do
    agt.reload # load the age_group_entries
    allow(competition).to receive(:signed_up_registrants).and_return([young_registrant, middle_registrant, old_registrant])
  end

  describe "#competition" do
    it "returns the competition" do
      expect(competition_sign_up.competition).to eq(competition)
    end
  end

  describe "#age_group_entries" do
    context "without an age group" do
      let(:competition) { FactoryGirl.create(:competition) }
      it "returns Male and Female" do
        expect(competition_sign_up.age_group_entries).to match_array([["Male", "Male"], ["Female", "Female"]])
      end
    end

    context "with an age group type" do
      it "returns The Age Groups" do
        expect(competition_sign_up.age_group_entries).to match_array([["old", "Male"], ["middle", "Male"], ["young", "Male"]])
      end
    end
  end

  describe "#signed_up_lists" do
    it "should return the competitors in each group" do
      expect(competition_sign_up.signed_up_list(young_description)).to eq([young_registrant])
      expect(competition_sign_up.signed_up_list(middle_description)).to eq([middle_registrant])
      expect(competition_sign_up.signed_up_list(old_description)).to eq([old_registrant])
    end
  end

  describe "#not_signed_up_lists" do
    let!(:other_young_registrant) { FactoryGirl.create(:registrant, :competitor, :minor, birthday: 5.years.ago) }
    let!(:other_middle_registrant) { FactoryGirl.create(:registrant, :competitor, :minor, birthday: 15.years.ago) }
    let!(:other_old_registrant) { FactoryGirl.create(:competitor, birthday: 36.years.ago) }

    context "within USA competitions" do
      let(:event_configuration) { FactoryGirl.create(:event_configuration, :with_usa) }

      it "should return the competitors NOT in each group" do
        expect(competition_sign_up.not_signed_up_list(young_description)).to eq([other_young_registrant])
        expect(competition_sign_up.not_signed_up_list(middle_description)).to eq([other_middle_registrant])
        expect(competition_sign_up.not_signed_up_list(old_description)).to eq([other_old_registrant])
      end
    end

    context "without USA competitions" do
      it "should return the competitors NOT in each group" do
        expect(competition_sign_up.not_signed_up_list(young_description)).to eq([])
        expect(competition_sign_up.not_signed_up_list(middle_description)).to eq([])
        expect(competition_sign_up.not_signed_up_list(old_description)).to eq([])
      end
    end
  end
end
