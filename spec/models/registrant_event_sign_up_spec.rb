# == Schema Information
#
# Table name: registrant_event_sign_ups
#
#  id                :integer          not null, primary key
#  registrant_id     :integer
#  signed_up         :boolean
#  event_category_id :integer
#  created_at        :datetime
#  updated_at        :datetime
#  event_id          :integer
#
# Indexes
#
#  index_registrant_event_sign_ups_event_category_id              (event_category_id)
#  index_registrant_event_sign_ups_event_id                       (event_id)
#  index_registrant_event_sign_ups_on_registrant_id_and_event_id  (registrant_id,event_id) UNIQUE
#  index_registrant_event_sign_ups_registrant_id                  (registrant_id)
#

require 'spec_helper'

describe RegistrantEventSignUp do
  before(:each) do
    @re = FactoryGirl.create(:registrant_event_sign_up)
  end
  it "is valid from FactoryGirl" do
    expect(@re.valid?).to eq(true)
  end
  it "requires an event_category" do
    @re.event_category = nil
    expect(@re.valid?).to eq(false)
  end

  it "requires a registrant" do
    @re.registrant = nil
    expect(@re.valid?).to eq(false)
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

  describe "when a competitor already exists and I un-sign up" do
    before :each do
      @competition = FactoryGirl.create(:competition)
      @competition_source = FactoryGirl.create(:competition_source, target_competition: @competition, event_category: @re.event_category)
      @competitor = FactoryGirl.create(:event_competitor, competition: @competition)
      @member = @competitor.members.first
      @member.update_attributes(registrant: @re.registrant)
      @re.reload
    end

    it "marks the member as dropped when I un-sign up for the competition" do
      @re.signed_up = false
      @re.save
      expect(@member.reload).to be_dropped_from_registration
    end

    describe "When the event has multiple categories" do
      before :each do
        @event = @re.event_category.event
        @cat2 = FactoryGirl.create(:event_category, event: @event)
      end

      it "marks the member as dropped when I change the category I signed up for" do
        @re.event_category = @cat2
        @re.save
        expect(@member.reload).to be_dropped_from_registration
      end
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

    expect(Competitor.last.status).to eq("active")
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
