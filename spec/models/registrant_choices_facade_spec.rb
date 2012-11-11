require 'spec_helper'

describe RegistrantChoicesFacade do
  before(:each) do
    @reg = FactoryGirl.create(:registrant)
    @ec = FactoryGirl.create(:event_choice)
    @rcf = RegistrantChoicesFacade.new(@reg)
  end

  it "has no value if boolean is not present" do
    @rcf.send(@ec.choicename).should == false
  end
  it "has no value if boolean is set to '0'" do
    rc = FactoryGirl.create(:registrant_choice, :registrant => @reg, :event_choice => @ec, :value => "0")
    @rcf.send(@ec.choicename).should == false
  end
  it "has true value if boolean is set to '1'" do
    rc = FactoryGirl.create(:registrant_choice, :registrant => @reg, :event_choice => @ec, :value => "1")
    @rcf.send(@ec.choicename).should == true
  end

  it "has sets value to '1' if is set to true" do
    @rcf.send("#{@ec.choicename}=", true)
    rc = RegistrantChoice.first
    rc.value.should == "1"
  end

  it "has sets value to '0' if is set to false" do
    @rcf.send("#{@ec.choicename}=", false)
    rc = RegistrantChoice.first
    rc.value.should == "0"
  end
end
