# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  position   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  info_url   :string(255)
#

require 'spec_helper'

describe Category do
  it "must have a name" do
    cat = Category.new
    cat.valid?.should == false
    cat.name = "Track"
    cat.valid?.should == true
  end

  it "has events" do
    cat = FactoryGirl.create(:category)
    ev = FactoryGirl.create(:event, :category => cat)
    cat.events.should == [ev]
  end

  it "displays its name as to_s" do
    cat = FactoryGirl.create(:category)
    cat.to_s.should == cat.name
  end
  describe "with multiple categories" do
    before(:each) do
      @category2 = FactoryGirl.create(:category, :position => 2)
      @category1 = FactoryGirl.create(:category, :position => 1)
    end
    it "lists them in position order" do
      Category.all.should == [@category1, @category2]
    end
  end

  it "events should be sorted by position" do
    cat = FactoryGirl.create(:category)
    event1 = FactoryGirl.create(:event, :category => cat, :position => 1)
    event3 = FactoryGirl.create(:event, :category => cat, :position => 3)
    event2 = FactoryGirl.create(:event, :category => cat, :position => 2)

    cat.events.should == [event1, event2, event3]
  end

  it "destroy related events upon destroy" do
    cat = FactoryGirl.create(:category)
    event1 = FactoryGirl.create(:event, :category => cat, :position => 1)
    Event.all.count.should == 1
    cat.destroy
    Event.all.count.should == 0
  end
end
