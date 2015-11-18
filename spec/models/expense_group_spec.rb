# == Schema Information
#
# Table name: expense_groups
#
#  id                         :integer          not null, primary key
#  visible                    :boolean          default(TRUE), not null
#  position                   :integer
#  created_at                 :datetime
#  updated_at                 :datetime
#  info_url                   :string(255)
#  competitor_free_options    :string(255)
#  noncompetitor_free_options :string(255)
#  competitor_required        :boolean          default(FALSE), not null
#  noncompetitor_required     :boolean          default(FALSE), not null
#  registration_items         :boolean          default(FALSE), not null
#  info_page_id               :integer
#

require 'spec_helper'

describe ExpenseGroup do
  let(:group) { FactoryGirl.create(:expense_group) }

  it "can be created by the factory" do
    expect(group).to be_valid
  end

  it "must have a name" do
    group.group_name = nil
    expect(group).to_not be_valid
  end

  it "must have a visible setting of true or false" do
    group.visible = nil
    expect(group).to be_invalid

    group.visible = true
    expect(group).to be_valid
  end

  it "cannot have both the info_page_id and info_url set" do
    group.info_page = FactoryGirl.create(:page)
    group.info_url = "http://www.google.com"
    expect(group).to be_invalid
  end

  it "can have the info_page_id set" do
    group.info_page = FactoryGirl.create(:page)
    expect(group).to be_valid
  end

  it "should have a nice to_s" do
    expect(group.to_s).to eq(group.group_name)
  end

  it "should only list the visible groups" do
    @group2 = FactoryGirl.create(:expense_group, visible: true)
    group # reference to build it
    ExpenseGroup.visible == [group]
  end

  it "can have an expense_group without a free_option value" do
    group.competitor_free_options = nil
    expect(group).to be_valid
  end
  it "can have an expense_group without a free_option value" do
    group.noncompetitor_free_options = nil
    expect(group).to be_valid
  end

  it "defaults to not required" do
    group = ExpenseGroup.new
    expect(group.competitor_required).to eq(false)
    expect(group.noncompetitor_required).to eq(false)
  end

  it "requires that the 'required' fields be set" do
    group.competitor_required = nil
    expect(group).to be_invalid

    group.competitor_required = false
    group.noncompetitor_required = nil
    expect(group).to be_invalid
  end

  describe "with expense_items" do
    before(:each) do
      @item2 = FactoryGirl.create(:expense_item, expense_group: group)
      @item1 = FactoryGirl.create(:expense_item, expense_group: group)
      @item2.update_attribute(:position, 2)
    end
    it "orders the items by position" do
      expect(group.expense_items).to eq([@item1, @item2])
    end
  end

  describe "with multiple expense groups" do
    before(:each) do
      group.position = 1
      group.visible = false
      group.save
      @group3 = FactoryGirl.create(:expense_group)
      @group2 = FactoryGirl.create(:expense_group)
      @group4 = FactoryGirl.create(:expense_group)
      @group3.update_attribute(:position, 3)
    end

    it "lists them in order" do
      expect(ExpenseGroup.all).to eq([group, @group2, @group3, @group4])
    end

    it "lists the 'visible' ones in order" do
      expect(ExpenseGroup.visible).to eq([@group2, @group3, @group4])
    end
  end
end
