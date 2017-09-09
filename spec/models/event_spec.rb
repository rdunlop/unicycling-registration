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
#  best_time_format            :string           default("none"), not null
#  standard_skill              :boolean          default(FALSE), not null
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

  context "#best_time_format" do
    it "requires a best_time_format" do
      @ev.best_time_format = nil
      expect(@ev).to be_invalid
    end

    it "allows h:mm best_time format" do
      @ev.best_time_format = "h:mm"
      expect(@ev).to be_valid
    end

    it "doesn't allow strange formats" do
      @ev.best_time_format = "bogus"
      expect(@ev).to be_invalid
    end
  end

  it "describes itself as StandardSkill if configured so" do
    expect(@ev.standard_skill?).to eq(false)
    @ev.standard_skill = true
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

  context "with a best time" do
    let(:event) { FactoryGirl.create(:event, :marathon_best_time_format) }

    it "counts more choices" do
      expect(event.num_choices).to eq(2)
    end
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
      @ec.event_category = nil
      @ec.save
      expect(@ev.num_signed_up_registrants).to eq(0)
    end
    it "will not count if no one has selected the choice" do
      event = FactoryGirl.create(:event)
      expect(event.num_signed_up_registrants).to eq(0)
    end

    describe "when we try to create associated expense items" do
      it "creates the registrant_expense_item" do
        expect do
          FactoryGirl.create(:expense_item, cost_element: @ev)
        end.to change(RegistrantExpenseItem, :count).by(1)

        expect(@ec.registrant.reload.registrant_expense_items.count).to eq(1)
      end
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
