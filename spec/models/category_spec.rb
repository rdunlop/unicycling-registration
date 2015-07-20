# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#  info_url   :string(255)
#

require 'spec_helper'

describe Category do
  it "must have a name" do
    cat = Category.new
    expect(cat.valid?).to eq(false)
    cat.name = "Track"
    expect(cat.valid?).to eq(true)
  end

  it "has events" do
    cat = FactoryGirl.create(:category)
    ev = FactoryGirl.create(:event, category: cat)
    expect(cat.events).to eq([ev])
  end

  it "displays its name as to_s" do
    cat = FactoryGirl.create(:category)
    expect(cat.to_s).to eq(cat.name)
  end
  describe "with multiple categories" do
    before(:each) do
      @category2 = FactoryGirl.create(:category)
      @category1 = FactoryGirl.create(:category)
      @category1.update_attribute(:position, 1)
    end

    it "lists them in position order" do
      expect(Category.all).to eq([@category1, @category2])
    end
  end

  it "events should be sorted by position" do
    cat = FactoryGirl.create(:category)
    event1 = FactoryGirl.create(:event, category: cat)
    event3 = FactoryGirl.create(:event, category: cat)
    event2 = FactoryGirl.create(:event, category: cat)
    event3.update_attribute(:position, 3)

    expect(cat.events).to eq([event1, event2, event3])
  end

  it "destroy related events upon destroy" do
    cat = FactoryGirl.create(:category)
    FactoryGirl.create(:event, category: cat)
    expect(Event.all.count).to eq(1)
    cat.destroy
    expect(Event.all.count).to eq(0)
  end
end
