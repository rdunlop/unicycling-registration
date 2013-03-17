require 'spec_helper'

describe AgeGroupType do
  it "must have a name" do
    agt = AgeGroupType.new
    agt.valid?.should == false
    agt.name = "Default"
    agt.valid?.should == true
  end

  describe "with a set of age group entries" do
    before(:each) do
      @agt = FactoryGirl.create(:age_group_type)
      @age1 = FactoryGirl.create(:age_group_entry, :age_group_type => @agt, :start_age => 0, :end_age => 10, :gender => "Male")
      @age2 = FactoryGirl.create(:age_group_entry, :age_group_type => @agt, :start_age => 11, :end_age => 100, :gender => "Male")
    end

    it "returns nil if no applicable age group entry is found" do
      @agt.age_group_entry_for(-1, "Male").should == nil
    end

    it "can return the correct age_group_entry for a given age" do
      @agt.age_group_entry_for(10, "Male").should == @age1
    end

    it "returns nil when given a female" do
      @agt.age_group_entry_for(10, "Female").should == nil
    end

    it "returns the age group entry if it is configured with 'mixed'" do
      @age1.gender = "Mixed"
      @age1.save!
      @agt.age_group_entry_for(10, "Female").should == @age1
    end
  end
end
