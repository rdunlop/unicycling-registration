require 'spec_helper'

describe ExpenseItemFreeChecker do
  # This is created with `!` so that the registrant validations
  # don't see the ExpenseGroup already existing.
  let!(:registrant) { FactoryBot.create(:competitor) }

  let(:subject) { described_class.new(registrant, expense_item) }

  describe "with an expense_group which REQUIRES one free item per group" do
    let(:expense_group) { FactoryBot.create(:expense_group) }
    let!(:expense_group_required_option) do
      FactoryBot.create(:expense_group_option, expense_group: expense_group, registrant_type: "competitor", option: ExpenseGroupOption::ONE_IN_GROUP_REQUIRED)
    end
    let!(:expense_group_free_option) do
      FactoryBot.create(:expense_group_option, expense_group: expense_group, registrant_type: "competitor", option: ExpenseGroupOption::ONE_FREE_IN_GROUP)
    end
    let(:expense_item) { FactoryBot.create(:expense_item, expense_group: expense_group) }

    it "marks the registrant as expense_item_is_free for this expense_item" do
      expect(subject.expense_item_is_free?).to eq(true)
    end
  end

  describe "with an expense_group which allows one free item per group" do
    let(:expense_group) { FactoryBot.create(:expense_group) }
    let!(:expense_group_free_option) do
      FactoryBot.create(:expense_group_option, expense_group: expense_group, registrant_type: "competitor", option: ExpenseGroupOption::ONE_FREE_IN_GROUP)
    end
    let(:expense_item) { FactoryBot.create(:expense_item, expense_group: expense_group) }

    it "marks the registrant as expense_item_is_free for this expense_item" do
      expect(subject.expense_item_is_free?).to eq(true)
    end

    describe "when it has a non-free item of the same expense_group (not free though)" do
      before do
        FactoryBot.create(:registrant_expense_item, registrant: registrant, line_item: expense_item)
        registrant.reload
      end

      it "shows that a free item is available" do
        expect(subject.expense_item_is_free?).to eq(true)
      end
    end

    describe "when it has a free expense_item" do
      before do
        FactoryBot.create(:registrant_expense_item, registrant: registrant, line_item: expense_item, free: true)
        registrant.reload
      end

      it "doesn't allow registrant to have 2 free of this group" do
        @rei = FactoryBot.build(:registrant_expense_item, registrant: registrant, line_item: expense_item, free: true)
        expect(subject).to be_free_item_already_exists
      end
    end

    describe "when it has a paid expense_item" do
      let(:expense_item) { FactoryBot.create(:expense_item, expense_group: expense_group) }

      before do
        @pay = FactoryBot.create(:payment)
        @pei = FactoryBot.create(:payment_detail, registrant: registrant, payment: @pay, line_item: expense_item, free: true)
        @pay.reload
        @pay.completed = true
        @pay.save!
        registrant.reload
      end

      it "shows that it has the given expense_group" do
        expect(subject).to be_free_item_already_exists
      end
    end
  end

  describe "with an expense_group which allows one free item per item in group" do
    let(:expense_group) { FactoryBot.create(:expense_group) }
    let!(:expense_group_free_option) do
      FactoryBot.create(:expense_group_option, expense_group: expense_group, registrant_type: "competitor", option: ExpenseGroupOption::ONE_FREE_OF_EACH_IN_GROUP)
    end
    let(:expense_item) { FactoryBot.create(:expense_item, expense_group: expense_group) }

    it "marks the registrant as expense_item_is_free for this expense_item" do
      expect(subject.expense_item_is_free?).to eq(true)
    end

    describe "when it has a non-free item of the same expense_group (not free though)" do
      before do
        FactoryBot.create(:registrant_expense_item, registrant: registrant, line_item: expense_item)
        registrant.reload
      end

      it "shows that a free item is available" do
        expect(subject.expense_item_is_free?).to eq(true)
      end
    end

    describe "when it has a free expense_item" do
      before do
        FactoryBot.create(:registrant_expense_item, registrant: registrant, line_item: expense_item, free: true)
        registrant.reload
      end

      it "doesn't allow registrant to have 2 free of this expense_item" do
        @rei = FactoryBot.build(:registrant_expense_item, registrant: registrant, line_item: expense_item, free: true)
        expect(subject).to be_free_item_already_exists
      end

      it "allows different free expense_items in the same group" do
        expense_item2 = FactoryBot.create(:expense_item, expense_group: expense_group)
        @rei = FactoryBot.build(:registrant_expense_item, registrant: registrant, line_item: expense_item2, free: true)
        expect(@rei).to be_valid
      end
    end
  end
end
