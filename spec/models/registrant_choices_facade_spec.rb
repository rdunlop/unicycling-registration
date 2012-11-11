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

    it "has sets value to '0' if is set to false" do
      @rcf.send("#{@ec.choicename}=", "0")
      rc = RegistrantChoice.first
      rc.value.should == "0"
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
  end
end
