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
#

require 'spec_helper'

describe ExpenseGroup do
  before(:each) do
    @group = FactoryGirl.create(:expense_group)
  end
  it "can be created by the factory" do
    expect(@group.valid?).to eq(true)
  end
  it "must have a name" do
    @group.group_name = nil
    expect(@group.valid?).to eq(false)
  end
  it "must have a visible setting of true or false" do
    @group.visible = nil
    expect(@group.valid?).to eq(false)

    @group.visible = true
    expect(@group.valid?).to eq(true)
  end
  it "should have a nice to_s" do
    expect(@group.to_s).to eq(@group.group_name)
  end

  it "should only list the visible groups" do
    @group2 = FactoryGirl.create(:expense_group, :visible => true)
    ExpenseGroup.visible == [@group]
  end

  it "can have an expense_group without a free_option value" do
    @group.competitor_free_options = nil
    expect(@group.valid?).to eq(true)
  end
  it "can have an expense_group without a free_option value" do
    @group.noncompetitor_free_options = nil
    expect(@group.valid?).to eq(true)
  end

  it "defaults to not required" do
    @group = ExpenseGroup.new
    expect(@group.competitor_required).to eq(false)
    expect(@group.noncompetitor_required).to eq(false)
  end

  it "requires that the 'required' fields be set" do
    @group.competitor_required = nil
    expect(@group.valid?).to eq(false)
    @group.competitor_required = false
    @group.noncompetitor_required = nil
    expect(@group.valid?).to eq(false)
  end

  describe "with expense_items" do
    before(:each) do
      @item2 = FactoryGirl.create(:expense_item, :expense_group => @group, :position => 2)
      @item1 = FactoryGirl.create(:expense_item, :expense_group => @group, :position => 1)
    end
    it "orders the items by position" do
      expect(@group.expense_items).to eq([@item1, @item2])
    end
  end

  describe "with multiple expense groups" do
    before(:each) do
      @group.position = 1
      @group.visible = false
      @group.save
      @group3 = FactoryGirl.create(:expense_group, :position => 3)
      @group2 = FactoryGirl.create(:expense_group, :position => 2)
      @group4 = FactoryGirl.create(:expense_group, :position => 4)
    end

    it "lists them in order" do
      expect(ExpenseGroup.all).to eq([@group, @group2, @group3, @group4])
    end

    it "lists the 'visible' ones in order" do
      expect(ExpenseGroup.visible).to eq([@group2, @group3, @group4])
    end
  end

end
