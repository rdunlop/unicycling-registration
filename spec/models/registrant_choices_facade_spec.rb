require 'spec_helper'

describe RegistrantChoicesFacade do
  before(:each) do
    @reg = FactoryGirl.create(:registrant)
    @rcf = RegistrantChoicesFacade.new(@reg)
  end

  describe "for a boolean choice" do
    before(:each) do
      @ec = FactoryGirl.create(:event_choice)
    end

    it "has false value if boolean is not present" do
      @rcf.send(@ec.choicename).should == false
    end

    it "has false value if boolean is set to '0'" do
      rc = FactoryGirl.create(:registrant_choice, :registrant => @reg, :event_choice => @ec, :value => "0")
      @rcf.send(@ec.choicename).should == false
    end

    it "has true value if boolean is set to '1'" do
      rc = FactoryGirl.create(:registrant_choice, :registrant => @reg, :event_choice => @ec, :value => "1")
      @rcf.send(@ec.choicename).should == true
    end

    it "has sets value to '1' if is set to true" do
      @rcf.send("#{@ec.choicename}=", "1")
      rc = RegistrantChoice.first
      rc.value.should == "1"
    end

    it "has deletes the entryif it is set to false" do
      rc = FactoryGirl.create(:registrant_choice, :registrant => @reg, :event_choice => @ec, :value => "1")
      @rcf.send("#{@ec.choicename}=", "0")
      RegistrantChoice.count.should == 0
    end
  end

  describe "with a 'text' choice" do
    before(:each) do
      @ec = FactoryGirl.create(:event_choice, :cell_type => 'text')
    end

    it "has nil value if reg_choice is not present" do
      @rcf.send(@ec.choicename).should == nil
    end
    it "has '' value if text is set to ''" do
      rc = FactoryGirl.create(:registrant_choice, :registrant => @reg, :event_choice => @ec, :value => "")
      @rcf.send(@ec.choicename).should == ''
    end
    it "has 'hello' value if text is set to 'hello'" do
      rc = FactoryGirl.create(:registrant_choice, :registrant => @reg, :event_choice => @ec, :value => "hello")
      @rcf.send(@ec.choicename).should == 'hello'
    end

    it "sets value to 'hello' if it is set to 'hello'" do
      @rcf.send("#{@ec.choicename}=", "Hello")
      rc = RegistrantChoice.first
      rc.value.should == "Hello"
    end
    it "deletes the entry if set to ''" do
      rc = FactoryGirl.create(:registrant_choice, :registrant => @reg, :event_choice => @ec, :value => "hello")
      @rcf.send("#{@ec.choicename}=", "")
      RegistrantChoice.count.should == 0
    end
  end
  
  describe "with a 'multiple' choice" do
    before(:each) do
      @ec = FactoryGirl.create(:event_choice, :cell_type => 'multiple')
    end

    it "has nil value if reg_choice is not present" do
      @rcf.send(@ec.choicename).should == nil
    end

    it "has '' value if text is set to ''" do
      rc = FactoryGirl.create(:registrant_choice, :registrant => @reg, :event_choice => @ec, :value => "")
      @rcf.send(@ec.choicename).should == ''
    end
    it "has 'hello' value if text is set to 'hello'" do
      rc = FactoryGirl.create(:registrant_choice, :registrant => @reg, :event_choice => @ec, :value => "hello")
      @rcf.send(@ec.choicename).should == 'hello'
    end

    it "sets value to 'hello' if it is set to 'hello'" do
      @rcf.send("#{@ec.choicename}=", "Hello")
      rc = RegistrantChoice.first
      rc.value.should == "Hello"
    end
    it "deletes the entry if set to ''" do
      rc = FactoryGirl.create(:registrant_choice, :registrant => @reg, :event_choice => @ec, :value => "hello")
      @rcf.send("#{@ec.choicename}=", "")
      RegistrantChoice.count.should == 0
    end
  end

  describe "with a boolean choice event" do
    before(:each) do
      @event = FactoryGirl.create(:event)
      @ec = FactoryGirl.create(:event_choice, :event => @event)
      rc = FactoryGirl.create(:registrant_choice, :registrant => @reg, :event_choice => @ec, :value => "1")
    end
    it "can determine whether it has the event" do
      @rcf.has_event?(@event).should == true
      @rcf.has_event?(FactoryGirl.create(:event)).should == false
    end
    it "can describe the event" do
      @rcf.describe_event(@event).should == @event.name
    end
    describe "and a text field" do
      before(:each) do
        @ec2 = FactoryGirl.create(:event_choice, :event => @event, :label => "Team", :position => 2, :cell_type => "text")
        @rc2 = FactoryGirl.create(:registrant_choice, :registrant => @reg, :event_choice => @ec2, :value => "My Team")
      end
      it "can describe the event" do
        @rcf.describe_event(@event).should == "#{@event.name} - #{@ec2.label}: #{@rc2.value}"
      end
    end
    describe "and a select field" do
      before(:each) do
        @ec2 = FactoryGirl.create(:event_choice, :event => @event, :label => "Category", :position => 2, :cell_type => "multiple")
        @rc2 = FactoryGirl.create(:registrant_choice, :registrant => @reg, :event_choice => @ec2, :value => "Advanced")
      end
      it "can describe the event" do
        @rcf.describe_event(@event).should == "#{@event.name} - #{@ec2.label}: #{@rc2.value}"
      end
      it "doesn't break without a registrant choice" do
        @rc2.destroy
        @rcf.describe_event(@event).should == "#{@event.name}"
      end
    end
  end
end
