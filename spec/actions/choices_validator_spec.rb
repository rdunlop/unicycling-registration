require 'spec_helper'

describe ChoicesValidator do
  before(:each) do
    @reg = FactoryGirl.create(:competitor)
  end

  describe "with a boolean choice event" do
    before(:each) do
      @event = FactoryGirl.create(:event)
      @ec = @event.event_categories.first
      rc = FactoryGirl.create(:registrant_event_sign_up, :registrant => @reg, :event => @event, :event_category => @ec, :signed_up => true)
    end
    it "can determine whether it has the event" do
      expect(@reg.has_event?(@event)).to eq(true)
      expect(@reg.has_event?(FactoryGirl.create(:event))).to eq(false)
    end
    it "can describe the event" do
      expect(@reg.describe_event(@event)).to eq(@event.name)
    end
    it "can determine whether it has the category" do
      expect(@reg.has_event_in_category?(@event.category)).to eq(true)
      expect(@reg.has_event_in_category?(FactoryGirl.create(:category))).to eq(false)
    end
    describe "and a text field" do
      before(:each) do
        @ec2 = FactoryGirl.create(:event_choice, :event => @event, :label => "Team", :cell_type => "text")
        @rc2 = FactoryGirl.create(:registrant_choice, :registrant => @reg, :event_choice => @ec2, :value => "My Team")
      end
      it "can describe the event" do
        expect(@reg.describe_event(@event)).to eq("#{@event.name} - #{@ec2.label}: #{@rc2.value}")
      end
    end
    describe "and a select field" do
      before(:each) do
        @ec2 = FactoryGirl.create(:event_choice, :event => @event, :label => "Category", :cell_type => "multiple")
        @rc2 = FactoryGirl.create(:registrant_choice, :registrant => @reg, :event_choice => @ec2, :value => "Advanced")
      end
      it "can describe the event" do
        expect(@reg.describe_event(@event)).to eq("#{@event.name} - #{@ec2.label}: #{@rc2.value}")
      end
      it "doesn't break without a registrant choice" do
        @rc2.destroy
        expect(@reg.describe_event(@event)).to eq("#{@event.name}")
      end
    end
  end

  describe "with a single event_choices for an event" do
    before(:each) do
      @ev = FactoryGirl.create(:event)
      @ec1 = @ev.event_categories.first
    end

    it "is valid without having selection" do
      expect(@reg.valid?).to eq(true)
    end
    it "is valid when having checked off this event" do
      FactoryGirl.create(:registrant_event_sign_up, :event => @ev, :event_category => @ec1, :signed_up => true, :registrant => @reg)
      expect(@reg.valid?).to eq(true)
    end
    describe "with a second (boolean) event_choice for an event" do
      before(:each) do
        @ec2 = FactoryGirl.create(:event_choice, :event => @ev)
      end
      it "should be valid if we only check off the primary_choice" do
        FactoryGirl.create(:registrant_event_sign_up, :event => @ev, :event_category => @ec1, :signed_up => true, :registrant => @reg)
        @reg.reload
        expect(@reg.valid?).to eq(true)
      end
      it "should be valid if we check off both event_choices" do
        @reg.reload
        expect(@reg.valid?).to eq(true)
        FactoryGirl.create(:registrant_event_sign_up, :event => @ev, :event_category => @ec1, :signed_up => true, :registrant => @reg)
        FactoryGirl.create(:registrant_choice, :event_choice => @ec2, :value => "1", :registrant => @reg)
        @reg.reload
        expect(@reg.valid?).to eq(true)
      end
      it "should be invalid if we only check off the second_choice" do
        FactoryGirl.create(:registrant_choice, :event_choice => @ec2, :value => "1", :registrant => @reg)
        FactoryGirl.create(:registrant_event_sign_up, :event => @ev, :event_category => @ec1, :signed_up => false, :registrant => @reg)
        @reg.reload
        expect(@reg.valid?).to eq(false)
      end
      it "should describe the event" do
        FactoryGirl.create(:registrant_choice, :event_choice => @ec2, :value => "1", :registrant => @reg)
        expect(@reg.describe_event(@ev)).to eq("#{@ev.name} - #{@ec2.label}: yes")
      end

      describe "with a text_field optional_if_event_choice to the boolean" do
        before(:each) do
          FactoryGirl.create(:registrant_event_sign_up, :event => @ev, :event_category => @ec1, :signed_up => true, :registrant => @reg)
          @ec3 = FactoryGirl.create(:event_choice, :event => @ev, :cell_type => "text", :optional_if_event_choice => @ec2)
          @reg.reload
        end

        it "allows the registrant to NOT specify a value for the text field if the checkbox is selected" do
          FactoryGirl.create(:registrant_choice, :event_choice => @ec2, :value => "1", :registrant => @reg)
          FactoryGirl.create(:registrant_choice, :event_choice => @ec3, :value => "", :registrant => @reg)
          @reg.reload
          expect(@reg.valid?).to eq(true)
        end

        it "REQUIRES the registrant specify a value for the text field if the checkbox is NOT selected" do
          FactoryGirl.create(:registrant_choice, :event_choice => @ec2, :value => "0", :registrant => @reg)
          FactoryGirl.create(:registrant_choice, :event_choice => @ec3, :value => "", :registrant => @reg)
          @reg.reload
          expect(@reg.valid?).to eq(false)
        end
      end
      describe "with a text_field required_if_event_choice" do
        before(:each) do
          FactoryGirl.create(:registrant_event_sign_up, :event => @ev, :event_category => @ec1, :signed_up => true, :registrant => @reg)
          @ec3 = FactoryGirl.create(:event_choice, :event => @ev, :cell_type => "text", :required_if_event_choice => @ec2)
          @reg.reload
        end

        it "requires the registrant to specify a value for the text field if the checkbox is selected" do
          FactoryGirl.create(:registrant_choice, :event_choice => @ec2, :value => "1", :registrant => @reg)
          rc = FactoryGirl.create(:registrant_choice, :event_choice => @ec3, :value => "", :registrant => @reg)
          @reg.reload
          expect(@reg.valid?).to eq(false)
          rc.value = "hello"
          rc.save
          @reg.reload
          expect(@reg.valid?).to eq(true)
        end

        it "allows the registrant to NOT specify a value for the text field if the checkbox is NOT selected" do
          FactoryGirl.create(:registrant_choice, :event_choice => @ec2, :value => "0", :registrant => @reg)
          FactoryGirl.create(:registrant_choice, :event_choice => @ec3, :value => "", :registrant => @reg)
          @reg.reload
          expect(@reg.valid?).to eq(true)
        end
      end
    end
    describe "with a second event_choice (text-style) for an event" do
      before(:each) do
        @ec2 = FactoryGirl.create(:event_choice, :event => @ev, :cell_type => "text")
      end
      it "should be invalid if we only check off the primary_choice" do
        FactoryGirl.create(:registrant_event_sign_up, :event => @ev, :event_category => @ec1, :signed_up => true, :registrant => @reg)
        @reg.reload
        expect(@reg.valid?).to eq(false)
      end
      it "should be valid if we fill in both event_choices" do
        FactoryGirl.create(:registrant_event_sign_up, :event => @ev, :event_category => @ec1, :signed_up => true, :registrant => @reg)
        FactoryGirl.create(:registrant_choice, :event_choice => @ec2, :value => "hello there", :registrant => @reg)
        @reg.reload
        expect(@reg.valid?).to eq(true)
      end
      it "should be valid if we don't choose the event, and we don't fill in the event_choice" do
        FactoryGirl.create(:registrant_event_sign_up, :event => @ev, :event_category => @ec1, :signed_up => false, :registrant => @reg)
        FactoryGirl.create(:registrant_choice, :event_choice => @ec2, :value => "", :registrant => @reg)
        @reg.reload
        expect(@reg.valid?).to eq(true)
      end
      it "should be invalid if we fill in only the second_choice" do
        FactoryGirl.create(:registrant_choice, :event_choice => @ec2, :value => "goodbye", :registrant => @reg)
        FactoryGirl.create(:registrant_event_sign_up, :event => @ev, :event_category => @ec1, :signed_up => false, :registrant => @reg)
        @reg.reload
        expect(@reg.valid?).to eq(false)
      end
      describe "if the second choices is optional" do
        before(:each) do
          @ec2.optional = true
          @ec2.save!
          @reg.reload
        end
        it "should allow empty registarnt_choice" do
          FactoryGirl.create(:registrant_event_sign_up, :event => @ev, :event_category => @ec1, :signed_up => true, :registrant => @reg)
          FactoryGirl.create(:registrant_choice, :event_choice => @ec2, :value => "", :registrant => @reg)
          @reg.reload
          expect(@reg.valid?).to eq(true)
        end
      end
    end
  end
  describe "when saving a registrant with multiple (invalid) registrant_choice" do
    before(:each) do
      @ei = FactoryGirl.create(:expense_item, :maximum_available => 1)
    end
    it "cannot save with 2 registrante_expense_items when only 1 should be possible" do
      @ei1 = @reg.registrant_expense_items.build({:expense_item_id => @ei.id})
      @ei2 = @reg.registrant_expense_items.build({:expense_item_id => @ei.id})
      expect(@reg.valid?).to eq(false)
    end
  end
end
