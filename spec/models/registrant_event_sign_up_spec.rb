# == Schema Information
#
# Table name: registrant_event_sign_ups
#
#  id                :integer          not null, primary key
#  registrant_id     :integer
#  signed_up         :boolean
#  event_category_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  event_id          :integer
#

require 'spec_helper'

describe RegistrantEventSignUp do
  before(:each) do
    @re = FactoryGirl.create(:registrant_event_sign_up)
  end
  it "is valid from FactoryGirl" do
    @re.valid?.should == true
  end
  it "requires an event_category" do
    @re.event_category = nil
    @re.valid?.should == false
  end

  it "requires a registrant" do
    @re.registrant = nil
    @re.valid?.should == false
  end

  describe "when an auto-competitor event exists" do
    before :each do
      @competition = FactoryGirl.create(:competition)
      @competition_source = FactoryGirl.create(:competition_source, target_competition: @competition, event_category: @re.event_category)
    end

    it "doesn't add the competition on change of state if the competition isn't auto-creation" do
      @re.reload
      @re.signed_up = false
      expect(@re.save).to be_truthy

      @re.signed_up = true
      expect {
        expect(@re.save).to be_truthy
      }.to change(Competitor, :count).by(0)
    end
  end
end

describe "when a competition exists before a sign-up" do
  let(:event_category) { FactoryGirl.create(:event).event_categories.first }
  before :each do
    @competition = FactoryGirl.create(:competition, automatic_competitor_creation: true, num_members_per_competitor: "One")
    @competition_source = FactoryGirl.create(:competition_source, target_competition: @competition, event_category: event_category)
  end

  it "adds the competition on change of state" do
    @re = FactoryGirl.create(:registrant_event_sign_up, event_category: event_category, signed_up: false)
    expect {
      expect(@re.save).to be_truthy
    }.to change(Competitor, :count).by(0)

    @re.signed_up = true
    expect {
      expect(@re.save).to be_truthy
    }.to change(Competitor, :count).by(1)
  end

  describe "but the gender filter is in effect" do
    before :each do
      @competition_source.update_attribute(:gender_filter, "Female")
    end

    it "doesn't add the competitor on change of state" do
      @re = FactoryGirl.create(:registrant_event_sign_up, event_category: event_category, signed_up: false)
      expect(@re.registrant.gender).to eq("Male")

       @re.signed_up = true
      expect {
        expect(@re.save).to be_truthy
      }.to change(Competitor, :count).by(0)
    end
  end
end
