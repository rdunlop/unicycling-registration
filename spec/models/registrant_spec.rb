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

  #it "requires country" do
    #@reg.gender = nil
    #@reg.valid?.should == false
  #end

  #it "requires city" do
    ##@reg.city = nil
    #@reg.valid?.should == false
  #end
  it "has either Male or Female gender" do
    @reg.gender = "Male"
    @reg.valid?.should == true

    @reg.gender = "Female"
    @reg.valid?.should == true

    @reg.gender = "Other"
    @reg.valid?.should == false
  end

  it "has a to_s" do
    @reg.to_s.should == @reg.first_name + " " + @reg.last_name
  end

  it "has event_choices" do
    @ec = FactoryGirl.create(:registrant_choice, :registrant => @reg)
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
  end

  describe "with a registrant_choice" do
    before(:each) do
      @rc = FactoryGirl.create(:registrant_choice, :registrant => @reg)
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
    it "a non-competior should owe different cost" do
      @noncomp = FactoryGirl.create(:noncompetitor)
      @noncomp.amount_owing.should == 50
    end

    it "creates an associated expense_item for a competitor" do
      @comp = FactoryGirl.create(:competitor)
      @comp.expense_items.count.should == 1
      @comp.expense_items.should == [@comp_exp]
    end

    it "creates an associated expense_item for a noncompetitor" do
      @comp = FactoryGirl.create(:noncompetitor)
      @comp.expense_items.count.should == 1
      @comp.expense_items.should == [@noncomp_exp]
    end

    describe "with a completed payment" do
      before(:each) do
        @comp = FactoryGirl.create(:competitor)
        @payment = FactoryGirl.create(:payment, :completed => true)
        @payment_detail = FactoryGirl.create(:payment_detail, :payment => @payment, :registrant => @comp, :amount => 100)
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
end
