require 'spec_helper'

describe ExpenseItemFreeChecker do
  let(:registrant) { FactoryGirl.create(:competitor) }

  let(:subject) { described_class.new(registrant, expense_item) }

  describe "with an expense_group which REQUIRES one free item per group" do
    let(:expense_group) { FactoryGirl.create(:expense_group, competitor_free_options: "One Free In Group REQUIRED") }
    let(:expense_item) { FactoryGirl.create(:expense_item, expense_group: expense_group) }

    it "marks the registrant as expense_item_is_free for this expense_item" do
      expect(subject.expense_item_is_free?).to eq(true)
    end
  end

  describe "with an expense_group which allows one free item per group" do
    let(:expense_group) { FactoryGirl.create(:expense_group, competitor_free_options: "One Free In Group") }
    let(:expense_item) { FactoryGirl.create(:expense_item, expense_group: expense_group) }

    it "marks the registrant as expense_item_is_free for this expense_item" do
      expect(subject.expense_item_is_free?).to eq(true)
    end

    describe "when it has a non-free item of the same expense_group (not free though)" do
      before(:each) do
        FactoryGirl.create(:registrant_expense_item, registrant: registrant, expense_item: expense_item)
        registrant.reload
      end

      it "shows that a free item is available" do
        expect(subject.expense_item_is_free?).to eq(true)
      end
    end

    describe "when it has a free expense_item" do
      before do
        FactoryGirl.create(:registrant_expense_item, registrant: registrant, expense_item: expense_item, free: true)
        registrant.reload
      end

      it "doesn't allow registrant to have 2 free of this group" do
        @rei = FactoryGirl.build(:registrant_expense_item, registrant: registrant, expense_item: expense_item, free: true)
        expect(subject.free_item_already_exists?).to be_truthy
      end
    end

    describe "when it has a paid expense_item" do
      let(:expense_item) { FactoryGirl.create(:expense_item, expense_group: expense_group) }

      before(:each) do
        @pay = FactoryGirl.create(:payment)
        @pei = FactoryGirl.create(:payment_detail, registrant: registrant, payment: @pay, expense_item: expense_item, free: true)
        @pay.reload
        @pay.completed = true
        @pay.save!
        registrant.reload
      end

      it "shows that it has the given expense_group" do
        expect(subject.free_item_already_exists?).to be_truthy
      end
    end
  end

  describe "with an expense_group which allows one free item per item in group" do
    let(:expense_group) { FactoryGirl.create(:expense_group, competitor_free_options: "One Free of Each In Group") }
    let(:expense_item) { FactoryGirl.create(:expense_item, expense_group: expense_group) }

    it "marks the registrant as expense_item_is_free for this expense_item" do
      expect(subject.expense_item_is_free?).to eq(true)
    end

    describe "when it has a non-free item of the same expense_group (not free though)" do
      before(:each) do
        FactoryGirl.create(:registrant_expense_item, registrant: registrant, expense_item: expense_item)
        registrant.reload
      end

      it "shows that a free item is available" do
        expect(subject.expense_item_is_free?).to eq(true)
      end
    end

    describe "when it has a free expense_item" do
      before do
        FactoryGirl.create(:registrant_expense_item, registrant: registrant, expense_item: expense_item, free: true)
        registrant.reload
      end

      it "doesn't allow registrant to have 2 free of this expense_item" do
        @rei = FactoryGirl.build(:registrant_expense_item, registrant: registrant, expense_item: expense_item, free: true)
        expect(subject.free_item_already_exists?).to be_truthy
      end

      it "allows different free expense_items in the same group" do
        expense_item2 = FactoryGirl.create(:expense_item, expense_group: expense_group)
        @rei = FactoryGirl.build(:registrant_expense_item, registrant: registrant, expense_item: expense_item2, free: true)
        expect(@rei).to be_valid
      end
    end
  end
end
