# == Schema Information
#
# Table name: events
#
#  id                          :integer          not null, primary key
#  category_id                 :integer
#  position                    :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  name                        :string(255)
#  visible                     :boolean          default(TRUE), not null
#  accepts_music_uploads       :boolean          default(FALSE), not null
#  artistic                    :boolean          default(FALSE), not null
#  accepts_wheel_size_override :boolean          default(FALSE), not null
#  event_categories_count      :integer          default(0), not null
#  event_choices_count         :integer          default(0), not null
#
# Indexes
#
#  index_events_category_id                     (category_id)
#  index_events_on_accepts_wheel_size_override  (accepts_wheel_size_override)
#

require 'spec_helper'

describe Event do
  before(:each) do
    @ev = FactoryGirl.create(:event)
  end
  it "is valid from FactoryGirl" do
    expect(@ev.valid?).to eq(true)
  end

  it "requires a category" do
    @ev.category = nil
    expect(@ev.valid?).to eq(false)
  end

  it "requires a name" do
    @ev.name = nil
    expect(@ev.valid?).to eq(false)
  end

  it "should have name as to_s" do
    expect(@ev.to_s).to eq(@ev.name)
  end

  it "describes itself as StandardSkill if named so" do
    expect(@ev.standard_skill?).to eq(false)
    @ev.name = "Standard Skill"
    @ev.save!
    expect(@ev.standard_skill?).to eq(true)
  end

  it "has many event_choices" do
    @ec = FactoryGirl.create(:event_choice, event: @ev)
    @ev.event_choices = [@ec]
  end

  it "sorts event choices by position" do
    @ec4 = FactoryGirl.create(:event_choice, event: @ev)
    @ec2 = FactoryGirl.create(:event_choice, event: @ev)
    @ec3 = FactoryGirl.create(:event_choice, event: @ev)
    @ec4.update_attribute(:position, 4)

    expect(@ev.event_choices).to eq([@ec2, @ec3, @ec4])
  end
  it "destroys associated event_choices upon destroy" do
    FactoryGirl.create(:event_choice, event: @ev)
    expect do
      @ev.destroy
    end.to change(EventChoice, :count).by(-1)
  end

  it "destroys associated event_categories upon destroy" do
    expect do
      @ev.destroy
    end.to change(EventCategory, :count).by(-1)
  end

  it "creates an associated event_category automatically" do
    expect(@ev.event_categories.count).to eq(1)
    @category = @ev.event_categories.first
    expect(@category.name).to eq('All')
    expect(@category.position).to eq(1)
  end

  it "has many event_categories" do
    @ecat1 = @ev.event_categories.first
    @ecat2 = FactoryGirl.create(:event_category, event: @ev, name: "Other")
    expect(@ev.event_categories).to eq([@ecat1, @ecat2])
  end

  describe "when a user has chosen an event" do
    before(:each) do
      @ev = FactoryGirl.create(:event)
      @ec = FactoryGirl.create(:registrant_event_sign_up, event: @ev, event_category: @ev.event_categories.first, signed_up: true)
    end

    it "will know that it is selected" do
      expect(@ev.num_signed_up_registrants).to eq(1)
    end
    it "will not count entries which are not selected" do
      @ec.signed_up = false
      @ec.save
      expect(@ev.num_signed_up_registrants).to eq(0)
    end
    it "will not count if no one has selected the choice" do
      event = FactoryGirl.create(:event)
      expect(event.num_signed_up_registrants).to eq(0)
    end
  end
  describe "when there is a director" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @user.add_role(:director, @ev)
    end

    it "has directors" do
      expect(@ev.directors).to eq([@user])
    end
  end
end
