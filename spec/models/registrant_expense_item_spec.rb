# == Schema Information
#
# Table name: registrant_expense_items
#
#  id                :integer          not null, primary key
#  registrant_id     :integer
#  line_item_id      :integer
#  created_at        :datetime
#  updated_at        :datetime
#  details           :string(255)
#  free              :boolean          default(FALSE), not null
#  system_managed    :boolean          default(FALSE), not null
#  locked            :boolean          default(FALSE), not null
#  custom_cost_cents :integer
#  line_item_type    :string
#
# Indexes
#
#  index_registrant_expense_items_registrant_id  (registrant_id)
#  registrant_expense_items_line_item            (line_item_id,line_item_type)
#

require 'spec_helper'

describe RegistrantExpenseItem do
  before(:each) do
    @rei = FactoryGirl.create(:registrant_expense_item)
    @ei = @rei.line_item
    @ei.cost = 20
    @ei.save
  end
  it "can be created by factory" do
    expect(@rei.valid?).to eq(true)
  end
  it "must have registrant" do
    @rei.registrant_id = nil
    expect(@rei.valid?).to eq(false)
  end
  it "must have expense_item" do
    @rei.line_item_id = nil
    expect(@rei.valid?).to eq(false)
  end

  describe "when the expense_item is custom_cost=true" do
    before(:each) do
      @ei = @rei.line_item
      @ei.has_custom_cost = true
      @ei.save
    end
    it "should require a custom_cost" do
      @rei.custom_cost = nil
      expect(@rei.valid?).to eq(false)
    end
    it "should be acceptable if the custom_cost is set" do
      @rei.custom_cost = 1
      expect(@rei.valid?).to eq(true)
    end

    it "should not allow a negative custom_cost" do
      @rei.custom_cost = -10
      expect(@rei.valid?).to eq(false)
    end
  end

  describe "when the expense item has fractional tax" do
    before :each do
      @ei = @rei.line_item
      @ei.cost = 17
      @ei.tax = 0.94
      @ei.save
    end

    it "should round" do
      expect(@rei.total_cost).to eq(17.94.to_money)
    end
  end

  describe "when the item is free" do
    before(:each) do
      @rei.free = true
      @rei.save
    end

    it "has a cost of 0" do
      expect(@rei.cost).to eq(0)
    end

    it "has 0 taxes" do
      expect(@rei.tax).to eq(0)
    end
  end
  it "must associate with the registrant" do
    @reg = FactoryGirl.create(:registrant)
    @rei = FactoryGirl.create(:registrant_expense_item, registrant: @reg)
    expect(@rei.registrant).to eq(@reg)
  end
  it "must associate with the expense_item" do
    @item = FactoryGirl.create(:expense_item)
    @rei = FactoryGirl.create(:registrant_expense_item, line_item: @item)
    expect(@rei.line_item).to eq(@item)
  end

  describe "with an expense_item with a limited number available" do
    before(:each) do
      @ei = FactoryGirl.create(:expense_item, maximum_available: 2)
    end

    it "allows creating a registrant expense_item" do
      @rei = FactoryGirl.build(:registrant_expense_item, line_item: @ei)
      expect(@rei.valid?).to eq(true)
    end

    it "allows creating the maximum amount" do
      @rei = FactoryGirl.build(:registrant_expense_item, line_item: @ei)
      expect(@rei.valid?).to eq(true)
      @rei.save!

      @rei2 = FactoryGirl.build(:registrant_expense_item, line_item: @ei)
      expect(@rei2.valid?).to eq(true)
      @rei2.save!
    end

    it "doesn't allow creating more than the maximum" do
      @rei = FactoryGirl.create(:registrant_expense_item, line_item: @ei)
      @rei2 = FactoryGirl.create(:registrant_expense_item, line_item: @ei)
      @ei.reload

      reg = @rei2.registrant
      reg.reload
      @rei3 = reg.registrant_expense_items.build(line_item: @ei)
      expect(reg.valid?).to eq(false)
    end
  end

  describe "with an expense_item with a limited number available PER REGISTRANT" do
    before(:each) do
      @ei = FactoryGirl.create(:expense_item, maximum_per_registrant: 1)
      @reg = FactoryGirl.create(:registrant)
    end

    it "allows creating a registrant expense_item" do
      @rei = FactoryGirl.build(:registrant_expense_item, line_item: @ei)
      expect(@rei.valid?).to eq(true)
    end

    it "doesn't allow creating more than the max amount" do
      @rei = FactoryGirl.build(:registrant_expense_item, registrant: @reg, line_item: @ei)
      expect(@rei.valid?).to eq(true)
      @rei.save!
      @reg.reload

      @rei2 = FactoryGirl.build(:registrant_expense_item, registrant: @reg, line_item: @ei)
      expect(@rei2.valid?).to eq(false)
    end

    it "allows creating max PER registrant" do
      @reg2 = FactoryGirl.create(:registrant)
      @rei = FactoryGirl.create(:registrant_expense_item, registrant: @reg, line_item: @ei)
      @rei2 = FactoryGirl.build(:registrant_expense_item, registrant: @reg2, line_item: @ei)

      expect(@rei2.valid?).to eq(true)
    end

    describe "when the limit is 2 per registrant" do
      before(:each) do
        @ei.maximum_per_registrant = 2
        @ei.save
      end

      it "can create 2 expense_items for the registrant" do
        @rei = FactoryGirl.create(:registrant_expense_item, registrant: @reg, line_item: @ei)
        @rei2 = FactoryGirl.build(:registrant_expense_item, registrant: @reg, line_item: @ei)
        expect(@rei2.valid?).to eq(true)
      end
    end
  end
end
