require 'spec_helper'

describe Registrant do
  before(:each) do
    @reg = FactoryGirl.create(:registrant)
  end

  it "has a valid reg from FactoryGirl" do
    @reg.valid?.should == true
  end

  it "requires a user" do
    @reg.user = nil
    @reg.valid?.should == false
  end

  it "must have a valid competitor value" do
    @reg.competitor = nil
    @reg.valid?.should == false
  end

  it "requires a birthday" do
    @reg.birthday = nil
    @reg.valid?.should == false
  end
  it "can not have a birthday, while having a configuration" do
    FactoryGirl.create(:event_configuration)
    @reg.birthday = nil
    @reg.valid?.should == false
  end

  it "requires first name" do
    @reg.first_name = nil
    @reg.valid?.should == false
  end

  it "requires last name" do
    @reg.last_name = nil
    @reg.valid?.should == false
  end

  it "requires gender" do
    @reg.gender = nil
    @reg.valid?.should == false
  end
  it "has no paid_expense_items" do
    @reg.paid_expense_items.should == []
  end

  it "has either Male or Female gender" do
    @reg.gender = "Male"
    @reg.valid?.should == true

    @reg.gender = "Female"
    @reg.valid?.should == true

    @reg.gender = "Other"
    @reg.valid?.should == false
  end

  it "requires country" do
    @reg.country = nil
    @reg.valid?.should == false
  end

  it "requires emergency_contact name" do
    @reg.emergency_name = nil
    @reg.valid?.should == false
  end

  it "requires emergency_contact relationship" do
    @reg.emergency_relationship = nil
    @reg.valid?.should == false
  end
  it "requires emergency_contact primary_phone" do
    @reg.emergency_primary_phone = nil
    @reg.valid?.should == false
  end

  it "has a to_s" do
    @reg.to_s.should == @reg.first_name + " " + @reg.last_name
  end

  it "has event_choices" do
    @ec = FactoryGirl.create(:registrant_choice, :registrant => @reg)
    @reg.reload
    @reg.registrant_choices.should == [@ec]
  end


  it "has a name field" do
    @reg.name.should == @reg.first_name + " " + @reg.last_name
  end
  it "has an owing cost of 0 by default" do
    @reg.amount_owing.should == 0
  end
  it "always displays the expenses_total" do
    @reg.expenses_total.should == 0
  end

  describe "with an expense_item" do
    before(:each) do
      @item = FactoryGirl.create(:expense_item)
      @rei = FactoryGirl.create(:registrant_expense_item, :registrant => @reg, :expense_item => @item)
    end
    it "has expense_items" do
      @reg.registrant_expense_items.should == [@rei]
      @reg.expense_items.should == [@item]
    end
    it "describes the expense_total as the sum" do
      @reg.expenses_total.should == @item.cost
    end
    it "lists the item as an owing_expense_item" do
      @reg.owing_expense_items.should == [@item]
    end
    describe "having paid for the item once, but still having it as a registrant_expense_item" do
      before(:each) do
        @payment = FactoryGirl.create(:payment, :completed => true)
        @payment_detail = FactoryGirl.create(:payment_detail, :payment => @payment, :registrant => @reg, :amount => @item.cost, :expense_item => @item)
      end
      it "lists one remaining item as owing" do
        @reg.owing_expense_items.should == [@item]
      end
      it "lists the item as paid for" do
        @reg.paid_expense_items.should == [@item]
      end
      it "should list the item twice in the all_expense_items" do
        @reg.all_expense_items.should == [@item, @item]
      end
      it "should list this for ALL registrants" do
        Registrant.all_expense_items.should == [@item, @item]
      end
      describe "with expenses from another registrant" do
        before(:each) do
          @ei = FactoryGirl.create(:expense_item)
          @rei2 = FactoryGirl.create(:registrant_expense_item, :expense_item => @ei)
        end
        it "has expenses from both registrants" do
          Registrant.all_expense_items.should =~ [@item, @item, @ei]
        end
      end
    end
  end

  describe "with a registrant_choice" do
    before(:each) do
      @rc = FactoryGirl.create(:registrant_choice, :registrant => @reg)
      @reg.reload
    end
    it "can access its registrant choices" do
      @reg.registrant_choices.should == [@rc]
    end
    it "can access the event_choices" do
      @reg.event_choices.should == [@rc.event_choice]
    end
    it "can access the events" do
      @reg.events.should == [@rc.event_choice.event]
    end
    it "can access the categories" do
      @reg.categories.should == [@rc.event_choice.event.category]
    end
    it "Destroys the related registrant_choice upon destroy" do
      RegistrantChoice.all.count.should == 1
      @reg.destroy
      RegistrantChoice.all.count.should == 0
    end
  end

  describe "with a registration_period" do
    before(:each) do
      @comp_exp = FactoryGirl.create(:expense_item, :cost => 100)
      @noncomp_exp = FactoryGirl.create(:expense_item, :cost => 50)
      @rp = FactoryGirl.create(:registration_period, :start_date => Date.new(2010,01,01), :end_date => Date.new(2022, 01, 01), :competitor_expense_item => @comp_exp, :noncompetitor_expense_item => @noncomp_exp)
    end

    describe "as a non-Competitor" do
      before(:each) do
        @noncomp = FactoryGirl.create(:noncompetitor)
      end
      it "should owe different cost" do
        @noncomp.amount_owing.should == 50
      end
      it "retrieves the non-comp registration_item" do
        @noncomp.registration_item.should == @noncomp_exp
      end
      it "lists the item as an owing_expense_item" do
        @noncomp.owing_expense_items.should == [@noncomp_exp]
      end
    end

    describe "as a Competitor" do
      before(:each) do
        @comp = FactoryGirl.create(:competitor)
      end
      it "retrieves the comp registration_item" do
        @comp.registration_item.should == @comp_exp
      end
      it "lists the item as an owing_expense_item" do
        @comp.owing_expense_items.should == [@comp_exp]
      end
    end

    describe "with an older (PAID_FOR) registration_period" do
      before(:each) do
        @oldcomp_exp = FactoryGirl.create(:expense_item, :cost => 90)
        @oldnoncomp_exp = FactoryGirl.create(:expense_item, :cost => 40)
        @rp = FactoryGirl.create(:registration_period, :start_date => Date.new(2009,01,01), :end_date => Date.new(2010, 01, 01), 
                                 :competitor_expense_item => @oldcomp_exp, :noncompetitor_expense_item => @oldnoncomp_exp)
        @comp = FactoryGirl.create(:competitor)
        @payment = FactoryGirl.create(:payment, :completed => true)
        @payment_detail = FactoryGirl.create(:payment_detail, :payment => @payment, :registrant => @comp, :amount => 90, :expense_item => @oldcomp_exp)
      end
      it "should return the older registration expense_item as the registration_item" do
        @comp.registration_item.should == @oldcomp_exp
      end
    end

    describe "with a completed payment" do
      before(:each) do
        @comp = FactoryGirl.create(:competitor)
        @payment = FactoryGirl.create(:payment, :completed => true)
        @payment_detail = FactoryGirl.create(:payment_detail, :payment => @payment, :registrant => @comp, :amount => 100, :expense_item => @comp_exp)
      end
      it "should have associated payment_details" do
        @comp.payment_details.should == [@payment_detail]
      end
      it "should have an amount_paid" do
        @comp.amount_paid.should == 100
      end
      it "should owe 0" do
        @comp.amount_owing.should == 0
      end
      it "lists the paid_expense_items" do
        @comp.paid_expense_items.should == [@payment_detail.expense_item]
      end
      it "lists no items as an owing_expense_item" do
        @comp.owing_expense_items.should == []
      end
      it "knows that the registration_fee has been paid" do
        @comp.reg_paid?.should == true
      end
    end

    describe "with an incomplete payment" do
      before(:each) do
        @comp = FactoryGirl.create(:competitor)
        @payment = FactoryGirl.create(:payment, :completed => false)
        @payment_detail = FactoryGirl.create(:payment_detail, :payment => @payment, :registrant => @comp, :amount => 100, :expense_item => @comp_exp)
      end
      it "should have associated payment_details" do
        @comp.payment_details.should == [@payment_detail]
      end
      it "should not have an amount_paid" do
        @comp.amount_paid.should == 0
      end
      it "should owe 100" do
        @comp.amount_owing.should == 100
      end
      it "lists the paid_expense_items" do
        @comp.paid_expense_items.should == []
      end
      it "lists no items as an owing_expense_item" do
        @comp.owing_expense_items.should == [@comp_exp]
      end
      it "knows that the registration_fee has NOT been paid" do
        @comp.reg_paid?.should == false
      end
    end
  end

  describe "with a boolean choice event" do
    before(:each) do
      @event = FactoryGirl.create(:event)
      @ec = @event.event_choices.first
      rc = FactoryGirl.create(:registrant_choice, :registrant => @reg, :event_choice => @ec, :value => "1")
    end
    it "can determine whether it has the event" do
      @reg.has_event?(@event).should == true
      @reg.has_event?(FactoryGirl.create(:event)).should == false
    end
    it "can describe the event" do
      @reg.describe_event(@event).should == @event.name
    end
    it "can determine whether it has the category" do
      @reg.has_event_in_category?(@event.category).should == true
      @reg.has_event_in_category?(FactoryGirl.create(:category)).should == false
    end
    describe "and a text field" do
      before(:each) do
        @ec2 = FactoryGirl.create(:event_choice, :event => @event, :label => "Team", :position => 2, :cell_type => "text")
        @rc2 = FactoryGirl.create(:registrant_choice, :registrant => @reg, :event_choice => @ec2, :value => "My Team")
      end
      it "can describe the event" do
        @reg.describe_event(@event).should == "#{@event.name} - #{@ec2.label}: #{@rc2.value}"
      end
    end
    describe "and a select field" do
      before(:each) do
        @ec2 = FactoryGirl.create(:event_choice, :event => @event, :label => "Category", :position => 2, :cell_type => "multiple")
        @rc2 = FactoryGirl.create(:registrant_choice, :registrant => @reg, :event_choice => @ec2, :value => "Advanced")
      end
      it "can describe the event" do
        @reg.describe_event(@event).should == "#{@event.name} - #{@ec2.label}: #{@rc2.value}"
      end
      it "doesn't break without a registrant choice" do
        @rc2.destroy
        @reg.describe_event(@event).should == "#{@event.name}"
      end
    end
  end

  describe "with a single event_choices for an event" do
    before(:each) do
      @ev = FactoryGirl.create(:event)
      @ec1 = @ev.primary_choice
    end

    it "is valid without having selection" do
      @reg.valid?.should == true
    end
    it "is valid when having checked off this event" do
      FactoryGirl.create(:registrant_choice, :event_choice => @ec1, :value => "1", :registrant => @reg)
      @reg.valid?.should == true
    end
    describe "with a second (boolean) event_choice for an event" do
      before(:each) do
        @ec2 = FactoryGirl.create(:event_choice, :event => @ev)
      end
      it "should be valid if we only check off the primary_choice" do
        FactoryGirl.create(:registrant_choice, :event_choice => @ec1, :value => "1", :registrant => @reg)
        @reg.reload
        @reg.valid?.should == true
      end
      it "should be valid if we check off both event_choices" do
        FactoryGirl.create(:registrant_choice, :event_choice => @ec1, :value => "1", :registrant => @reg)
        FactoryGirl.create(:registrant_choice, :event_choice => @ec2, :value => "1", :registrant => @reg)
        @reg.reload
        @reg.valid?.should == true
      end
      it "should be invalid if we only check off the second_choice" do
        FactoryGirl.create(:registrant_choice, :event_choice => @ec2, :value => "1", :registrant => @reg)
        FactoryGirl.create(:registrant_choice, :event_choice => @ec1, :value => "0", :registrant => @reg)
        @reg.reload
        @reg.valid?.should == false
      end
      it "should describe the event" do
        FactoryGirl.create(:registrant_choice, :event_choice => @ec2, :value => "1", :registrant => @reg)
        @reg.describe_event(@ev).should == "#{@ev.name} - #{@ec2.label}: yes"
      end
    end
    describe "with a second event_choice (text-style) for an event" do
      before(:each) do
        @ec2 = FactoryGirl.create(:event_choice, :event => @ev, :cell_type => "text")
      end
      it "should be invalid if we only check off the primary_choice" do
        FactoryGirl.create(:registrant_choice, :event_choice => @ec1, :value => "1", :registrant => @reg)
        @reg.reload
        @reg.valid?.should == false
      end
      it "should be valid if we fill in both event_choices" do
        FactoryGirl.create(:registrant_choice, :event_choice => @ec1, :value => "1", :registrant => @reg)
        FactoryGirl.create(:registrant_choice, :event_choice => @ec2, :value => "hello there", :registrant => @reg)
        @reg.reload
        @reg.valid?.should == true
      end
      it "should be invalid if we fill in only the second_choice" do
        FactoryGirl.create(:registrant_choice, :event_choice => @ec2, :value => "goodbye", :registrant => @reg)
        FactoryGirl.create(:registrant_choice, :event_choice => @ec1, :value => "0", :registrant => @reg)
        @reg.reload
        @reg.valid?.should == false
      end
    end
  end
  describe "with an event configuration (and starting date)" do
    before(:each) do
      FactoryGirl.create(:event_configuration, :start_date => Date.new(2012,05,20))
    end
    describe "and a registrant born on the starting day in 1982" do
      before(:each) do
        @reg.birthday = Date.new(1982, 05, 20)
      end
      it "should have an age of 30" do
        @reg.age.should == 30
      end
    end
    describe "and a registrant born the day after the starting date in 1982" do
      before(:each) do
        @reg.birthday = Date.new(1982, 05, 21)
      end
      it "should have an age of 29" do
        @reg.age.should == 29
      end
    end
    describe "with a 12 year old registrant" do
      before(:each) do
        @reg.birthday = Date.new(2000, 01, 22)
      end
      it "requires the responsible_adult_name" do
        @reg.responsible_adult_name = nil
        @reg.responsible_adult_phone = "Something"
        @reg.valid?.should == false
      end
      it "requires the responsible_adult_phone" do
        @reg.responsible_adult_name = "Something"
        @reg.responsible_adult_phone = nil
        @reg.valid?.should == false
      end
      it "is valid if name and phone are present" do
        @reg.responsible_adult_name = "Jane"
        @reg.responsible_adult_phone = "1-800-stuff"
        @reg.valid?.should == true
      end
    end
  end
end
