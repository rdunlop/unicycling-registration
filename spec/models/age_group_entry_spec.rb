# == Schema Information
#
# Table name: age_group_entries
#
#  id                :integer          not null, primary key
#  age_group_type_id :integer
#  short_description :string(255)
#  start_age         :integer
#  end_age           :integer
#  gender            :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  wheel_size_id     :integer
#

require 'spec_helper'

describe AgeGroupEntry do
  before(:each) do
    @age_group_entry = FactoryGirl.build_stubbed(:age_group_entry)
  end

  it "can be created by factorygirl" do
    @age_group_entry.valid?.should == true
  end

  it "requires an age_group_type" do
    @age_group_entry.age_group_type_id = nil
    @age_group_entry.valid?.should == false
  end

  it "requires a short_description" do
    @age_group_entry.short_description = nil
    @age_group_entry.valid?.should == false
  end

  it "can have the same short_description, as long as it has a different age_group_type" do
    age2 = FactoryGirl.build(:age_group_entry, :short_description => @age_group_entry.short_description)
    age2.valid?.should == true
  end

  it "has a wheel_size" do
    @age_group_entry.wheel_size = FactoryGirl.build_stubbed(:wheel_size)
  end


  it "requires gender be valid" do
    @age_group_entry.gender = nil
    @age_group_entry.valid?.should == false

    @age_group_entry.gender = "Male"
    @age_group_entry.valid?.should == true

    @age_group_entry.gender = "Female"
    @age_group_entry.valid?.should == true

    @age_group_entry.gender = "Mixed"
    @age_group_entry.valid?.should == true

    @age_group_entry.gender = "Other"
    @age_group_entry.valid?.should == false
  end
end
