require 'spec_helper'

describe "registrants/build/expenses" do
  let(:wizard_path) { "/" }
  before(:each) do
    FactoryGirl.create(:registration_cost, :competitor,
                       start_date: Date.new(2012, 1, 10),
                       end_date: Date.new(2012, 2, 11))
    @registrant = FactoryGirl.create(:competitor)
    allow(view).to receive(:wizard_path).and_return(wizard_path)
  end

  describe "with existing expense_items" do
    before(:each) do
      @item = FactoryGirl.create(:registrant_expense_item, registrant: @registrant)
      @registrant.reload
    end

    it "should render the details field, if enabled" do
      ei = @item.expense_item
      ei.has_details = true
      ei.details_label = "What is your family?"
      ei.save!

      render
      assert_select "label", text: "What is your family?"
      assert_select "input#registrant_expense_item_details", name: "registrant_expense_item[details]"
    end
  end
end
