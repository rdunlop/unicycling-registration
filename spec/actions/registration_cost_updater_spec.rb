require 'spec_helper'

describe "when testing the update function for registration costs", caching: true do
  let(:current_date) { Date.current }

  before do
    @reg = FactoryBot.create(:competitor) # will have rp1
    @nc_reg = FactoryBot.create(:noncompetitor) # will have rp1
    ActionMailer::Base.deliveries.clear
    # create a rp which encompasses "today"
    @comp_registration_cost1 = FactoryBot.create(:registration_cost, :competitor, start_date: Date.new(2012, 12, 21), end_date: current_date)
    @noncomp_registration_cost1 = FactoryBot.create(:registration_cost, :noncompetitor, start_date: Date.new(2012, 12, 21), end_date: current_date)
  end

  it "automatically has the current_period set" do
    expect(RegistrationCost.for_type("competitor").current_period).to eq(@comp_registration_cost1)
    expect(RegistrationCost.for_type("noncompetitor").current_period).to eq(@noncomp_registration_cost1)
  end

  it "says that an update has been performed recently" do
    expect(RegistrationCostUpdater.update_checked_recently?).to eq(true)
  end

  it "(when looking 3 days in the future) says that an update has not yet been done" do
    expect(RegistrationCostUpdater.update_checked_recently?(current_date + 3.days)).to eq(false)
  end

  it "initially, the registrant has an expense_item from the current period" do
    @reg.reload
    @nc_reg.reload
    expect(@reg.registrant_expense_items.count).to eq(1)
    expect(@reg.registrant_expense_items.first.line_item).to eq(@comp_registration_cost1.expense_items.first)
    expect(@nc_reg.registrant_expense_items.count).to eq(1)
    expect(@nc_reg.registrant_expense_items.first.line_item).to eq(@noncomp_registration_cost1.expense_items.first)
  end

  it "sends an e-mail when it changes the reg period" do
    num_deliveries = ActionMailer::Base.deliveries.size
    expect(num_deliveries).to eq(2) # 1 for Comp, 1 for NonComp
    expect(ActionMailer::Base.deliveries[0].subject).to eq("Updated Registration Period")
    expect(ActionMailer::Base.deliveries[1].subject).to eq("Updated Registration Period")
  end

  describe "when a registrant has a LOCKED registration_item" do
    before do
      @original_item = rei = @reg.registration_item
      rei.locked = true
      rei.save
    end

    it "doesn't update this registrants' items when moving to the next period" do
      FactoryBot.create(:registration_cost, :competitor, start_date: current_date + 1.day, end_date: current_date + 1.year)
      travel_to current_date + 1.month do
        RegistrationCostUpdater.new("competitor").update_current_period
      end
      @reg.reload
      expect(@reg.registration_item).to eq(@original_item)
    end
  end

  describe "when updating to the next period" do
    let!(:comp_registration_cost2) { FactoryBot.create(:registration_cost, :competitor, start_date: current_date + 1.day, end_date: current_date + 1.year) }
    let!(:noncomp_registration_cost2) { FactoryBot.create(:registration_cost, :noncompetitor, start_date: current_date + 1.day, end_date: current_date + 1.year) }

    before do
      ActionMailer::Base.deliveries.clear
      travel_to current_date + 1.month do
        @ret = RegistrationCostUpdater.new("competitor").update_current_period
        @ret = RegistrationCostUpdater.new("noncompetitor").update_current_period
      end
    end

    it "indicates that the new period has been recently updated" do
      expect(RegistrationCostUpdater.update_checked_recently?(current_date + 1.month + 1.day)).to eq(true)
    end

    it "indicates that it updated" do
      expect(@ret).to eq(true)
    end

    it "updates the current_period" do
      expect(RegistrationCost.for_type("competitor").current_period).to eq(comp_registration_cost2)
    end

    it "changes the registrant's item to the new period" do
      @reg.reload
      expect(@reg.registrant_expense_items.count).to eq(1)
      expect(@reg.registrant_expense_items.first.line_item).to eq(comp_registration_cost2.expense_items.first)

      @nc_reg.reload
      expect(@nc_reg.registrant_expense_items.count).to eq(1)
      expect(@nc_reg.registrant_expense_items.first.line_item).to eq(noncomp_registration_cost2.expense_items.first)
    end
  end

  describe "when updating to a non-existent period" do
    before do
      ActionMailer::Base.deliveries.clear
      travel_to current_date + 1.month do
        @ret = RegistrationCostUpdater.new("competitor").update_current_period
      end
    end

    it "indicates that it updated" do
      expect(@ret).to eq(true)
    end

    it "updates the current_period (which is nil)" do
      expect(RegistrationCost.for_type("competitor").current_period).to be_nil
    end

    it "sends an e-mail when it changes the reg period" do
      num_deliveries = ActionMailer::Base.deliveries.size
      expect(num_deliveries).to eq(1)
      email = ActionMailer::Base.deliveries.first
      expect(email.subject).to eq("Updated Registration Period")
    end

    it "does not delete the registrant's reg_item" do
      @reg.reload
      expect(@reg.registrant_expense_items.count).to eq(1)

      @nc_reg.reload
      expect(@nc_reg.registrant_expense_items.count).to eq(1)
    end

    describe "when updating to a now-existent period" do
      before do
        @comp_registration_cost2 = FactoryBot.create(:registration_cost, :competitor, start_date: current_date + 1.day, end_date: current_date + 1.year)
        @noncomp_registration_cost2 = FactoryBot.create(:registration_cost, :noncompetitor, start_date: current_date + 1.day, end_date: current_date + 1.year)
        travel_to current_date + 1.month do
          ActionMailer::Base.deliveries.clear
          @ret = RegistrationCostUpdater.new("competitor").update_current_period
          @ret = RegistrationCostUpdater.new("noncompetitor").update_current_period
        end
      end

      it "updates the current_period" do
        expect(RegistrationCost.for_type("competitor").current_period).to eq(@comp_registration_cost2)
      end

      it "sends an e-mail when it changes the reg period" do
        num_deliveries = ActionMailer::Base.deliveries.size
        expect(num_deliveries).not_to eq(0)
        email = ActionMailer::Base.deliveries.first
        expect(email.subject).to eq("Updated Registration Period")
      end

      it "changes the registrant's item to the new period" do
        @reg.reload
        expect(@reg.registrant_expense_items.count).to eq(1)
        expect(@reg.registrant_expense_items.first.line_item).to eq(@comp_registration_cost2.expense_items.first)

        @nc_reg.reload
        expect(@nc_reg.registrant_expense_items.count).to eq(1)
        expect(@nc_reg.registrant_expense_items.first.line_item).to eq(@noncomp_registration_cost2.expense_items.first)
      end
    end
  end
end
