# == Schema Information
#
# Table name: age_group_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_age_group_types_on_name  (name) UNIQUE
#

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

    describe "when searching a no-wheel-size age_group while using a wheel size" do
      before(:each) do
        @ws = FactoryGirl.create(:wheel_size_20)
      end
      it "still finds the age group entry" do
        @agt.age_group_entry_for(10, "Male", @ws.id).should == @age1
      end
    end

    describe "When the age_group_entry has a wheel size" do
      before(:each) do
        @ws20 = FactoryGirl.create(:wheel_size_20)
        @ws24 = FactoryGirl.create(:wheel_size_24)
        @age1.wheel_size = @ws20
        @age1.save
        @age1b = FactoryGirl.create(:age_group_entry, :age_group_type => @agt, :start_age => 0, :end_age => 12, :gender => "Male", :wheel_size => @ws24)
      end
      it "puts the rider on a 20\" wheel in the correct age group" do
        @agt.age_group_entry_for(10, "Male", @ws20).should == @age1
      end
      it "puts the rider on a 24\" wheel in the correct age group" do
        @agt.age_group_entry_for(10, "Male", @ws24).should == @age1b
      end
    end
  end

  it "must have a unique name" do
    agt = FactoryGirl.create(:age_group_type)
    agt2 = FactoryGirl.build(:age_group_type, :name => agt.name)
    agt2.valid?.should == false
  end
end
