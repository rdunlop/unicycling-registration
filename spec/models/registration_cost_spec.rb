# == Schema Information
#
# Table name: registration_costs
#
#  id              :integer          not null, primary key
#  start_date      :date
#  end_date        :date
#  expense_item_id :integer
#  registrant_type :string           not null
#  onsite          :boolean          default(FALSE), not null
#  current_period  :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_registration_costs_on_current_period                      (current_period)
#  index_registration_costs_on_registrant_type_and_current_period  (registrant_type,current_period)
#

require 'spec_helper'

describe RegistrationCost do
  let(:registration_cost) { FactoryGirl.build(:registration_cost, :competitor, start_date: Date.new(2012, 11, 03), end_date: Date.new(2012, 11, 07)) }

  it "is valid from FactoryGirl" do
    expect(registration_cost.valid?).to eq(true)
  end

  it "must have a start date" do
    registration_cost.start_date = nil
    expect(registration_cost.valid?).to eq(false)
  end

  it "must have an end date" do
    registration_cost.end_date = nil
    expect(registration_cost.valid?).to eq(false)
  end

  it "must have an expense_item" do
    registration_cost.expense_item = nil
    expect(registration_cost.valid?).to eq(false)
  end

  it "must have onsite set" do
    registration_cost.onsite = nil
    expect(registration_cost.valid?).to eq(false)
  end

  it "is not onsite by default" do
    rp = RegistrationCost.new
    expect(rp.onsite).to eq(false)
  end

  it "can determine the last online registration period" do
    registration_cost.save!
    expect(RegistrationCost.last_online_period).to eq(registration_cost)
  end

  describe "with associated expense_items" do
    let!(:expense_item) { registration_cost.expense_item }

    it "removes the expense item on RegistrationCost deletion" do
      registration_cost.save!
      registration_cost.destroy
      expect(expense_item).to be_destroyed
    end

    describe "when the expense_item has a payment" do
      before do
        registration_cost.save!
        FactoryGirl.create :payment_detail, expense_item: registration_cost.expense_item
      end

      it "can't remove the RegistrationCost on deletion" do
        expect { registration_cost.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
      end
    end
  end

  describe "with existing periods" do
    let!(:comp_registration_cost1) { FactoryGirl.create(:registration_cost, :competitor, start_date: Date.new(2012, 01, 01), end_date: Date.new(2012, 02, 02)) }
    let!(:noncomp_registration_cost1) { FactoryGirl.create(:registration_cost, :noncompetitor, start_date: Date.new(2012, 01, 01), end_date: Date.new(2012, 02, 02)) }
    let!(:comp_registration_cost2) { FactoryGirl.create(:registration_cost, :competitor, start_date: Date.new(2012, 02, 03), end_date: Date.new(2012, 04, 04)) }
    let!(:noncomp_registration_cost2) { FactoryGirl.create(:registration_cost, :noncompetitor, start_date: Date.new(2012, 02, 03), end_date: Date.new(2012, 04, 04)) }

    it "can retrieve only the competitor periods" do
      expect(RegistrationCost.for_type("competitor")).to match_array([comp_registration_cost1, comp_registration_cost2])
    end

    it "can retrieve only the noncompetitor periods" do
      expect(RegistrationCost.for_type("noncompetitor")).to match_array([noncomp_registration_cost1, noncomp_registration_cost2])
    end

    it "can retrieve the expense items for only a set of the registration_costs" do
      expect(RegistrationCost.for_type("competitor").all_registration_expense_items).to match_array([
                                                                                                      comp_registration_cost1.expense_item,
                                                                                                      comp_registration_cost2.expense_item
                                                                                                    ])
      expect(RegistrationCost.for_type("noncompetitor").all_registration_expense_items).to match_array([
                                                                                                         noncomp_registration_cost1.expense_item,
                                                                                                         noncomp_registration_cost2.expense_item
                                                                                                       ])
    end

    it "can retrieve period" do
      expect(RegistrationCost.relevant_period("competitor", Date.new(2012, 01, 15))).to eq(comp_registration_cost1)
    end

    it "gets nil for missing section" do
      expect(RegistrationCost.relevant_period("competitor", Date.new(2010, 01, 01))).to be_nil
    end

    it "returns the first registration period INCLUDING the day AFTER the period ends" do
      expect(RegistrationCost.relevant_period("competitor", Date.new(2012, 02, 03))).to eq(comp_registration_cost1)
    end

    it "returns the second registration period +2 days after the first period ends" do
      expect(RegistrationCost.relevant_period("competitor", Date.new(2012, 02, 04))).to eq(comp_registration_cost2)
    end

    it "disregards onsite registration periods for last_online_period" do
      registration_cost.onsite = true
      registration_cost.save!
      expect(RegistrationCost.for_type("competitor").last_online_period).to eq(comp_registration_cost2)
    end
    describe "with more registration periods" do
      let!(:comp_registration_cost0) { FactoryGirl.create(:registration_cost, :competitor, start_date: Date.new(2010, 02, 03), end_date: Date.new(2010, 04, 04)) }

      it "returns the periods in ascending date order" do
        registration_cost.save!
        expect(RegistrationCost.for_type("competitor").all).to eq([comp_registration_cost0, comp_registration_cost1, comp_registration_cost2, registration_cost])
      end
    end

    it "can identify the current period" do
      expect(comp_registration_cost1.current_period?(Date.new(2012, 01, 14))).to eq(true)
      expect(comp_registration_cost2.current_period?(Date.new(2012, 01, 14))).to eq(false)
      expect(noncomp_registration_cost1.current_period?(Date.new(2012, 01, 14))).to eq(true)
      expect(noncomp_registration_cost2.current_period?(Date.new(2012, 01, 14))).to eq(false)
    end
    it "can identify past periods" do
      expect(comp_registration_cost1.past_period?(Date.new(2012, 02, 20))).to eq(true)
      expect(comp_registration_cost2.past_period?(Date.new(2012, 02, 20))).to eq(false)
      expect(noncomp_registration_cost1.past_period?(Date.new(2012, 02, 20))).to eq(true)
      expect(noncomp_registration_cost2.past_period?(Date.new(2012, 02, 20))).to eq(false)
    end
  end
end

describe "when testing the update function for registration costs", caching: true do
  before(:each) do
    ActionMailer::Base.deliveries.clear
    # create a rp which encompasses "today"
    @comp_registration_cost1 = FactoryGirl.create(:registration_cost, :competitor, start_date: Date.new(2012, 12, 21), end_date: Date.new(2020, 11, 7))
    @noncomp_registration_cost1 = FactoryGirl.create(:registration_cost, :noncompetitor, start_date: Date.new(2012, 12, 21), end_date: Date.new(2020, 11, 7))
    @reg = FactoryGirl.create(:competitor) # will have rp1
    @nc_reg = FactoryGirl.create(:noncompetitor) # will have rp1
  end
  it "automically has the current_period set already" do
    expect(RegistrationCost.for_type("competitor").current_period).to eq(@comp_registration_cost1)
    expect(RegistrationCost.for_type("noncompetitor").current_period).to eq(@noncomp_registration_cost1)
  end

  it "says that an update has been performed recently" do
    expect(RegistrationCost.update_checked_recently?).to eq(true)
  end

  it "(when looking 3 days in the future) says that an update has not yet been done" do
    expect(RegistrationCost.update_checked_recently?(Date.today + 3.days)).to eq(false)
  end

  it "initially, the registrant has an expense_item from the current period" do
    expect(@reg.registrant_expense_items.count).to eq(1)
    expect(@reg.registrant_expense_items.first.expense_item).to eq(@comp_registration_cost1.expense_item)
    expect(@nc_reg.registrant_expense_items.count).to eq(1)
    expect(@nc_reg.registrant_expense_items.first.expense_item).to eq(@noncomp_registration_cost1.expense_item)
  end

  it "sends an e-mail when it changes the reg period" do
    num_deliveries = ActionMailer::Base.deliveries.size
    expect(num_deliveries).to eq(2) # 1 for Comp, 1 for NonComp
  end

  describe "when a registrant has a LOCKED registration_item" do
    before(:each) do
      @original_item = rei = @reg.registration_item
      rei.locked = true
      rei.save
    end

    it "doesnt't update this registrants' items when moving to the next period" do
      FactoryGirl.create(:registration_cost, :competitor, start_date: Date.new(2020, 11, 8), end_date: Date.new(2021, 1, 1))
      travel_to Date.new(2020, 12, 1) do
        RegistrationCost.update_current_period("competitor")
      end
      @reg.reload
      expect(@reg.registration_item).to eq(@original_item)
    end
  end
  describe "when updating to the next period" do
    let!(:comp_registration_cost2) { FactoryGirl.create(:registration_cost, :competitor, start_date: Date.new(2020, 11, 8), end_date: Date.new(2021, 1, 1)) }
    let!(:noncomp_registration_cost2) { FactoryGirl.create(:registration_cost, :noncompetitor, start_date: Date.new(2020, 11, 8), end_date: Date.new(2021, 1, 1)) }

    before(:each) do
      ActionMailer::Base.deliveries.clear
      travel_to Date.new(2020, 12, 1) do
        @ret = RegistrationCost.update_current_period("competitor")
        @ret = RegistrationCost.update_current_period("noncompetitor")
      end
    end

    it "it indicates that the new period has been recently updated" do
      expect(RegistrationCost.update_checked_recently?(Date.new(2020, 12, 2))).to eq(true)
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
      expect(@reg.registrant_expense_items.first.expense_item).to eq(comp_registration_cost2.expense_item)

      @nc_reg.reload
      expect(@nc_reg.registrant_expense_items.count).to eq(1)
      expect(@nc_reg.registrant_expense_items.first.expense_item).to eq(noncomp_registration_cost2.expense_item)
    end
  end

  describe "when updating to a non-existent period" do
    before(:each) do
      ActionMailer::Base.deliveries.clear
      travel_to Date.new(2020, 12, 1) do
        @ret = RegistrationCost.update_current_period("competitor")
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
      before(:each) do
        @comp_registration_cost2 = FactoryGirl.create(:registration_cost, :competitor, start_date: Date.new(2020, 11, 8), end_date: Date.new(2021, 1, 1))
        @noncomp_registration_cost2 = FactoryGirl.create(:registration_cost, :noncompetitor, start_date: Date.new(2020, 11, 8), end_date: Date.new(2021, 1, 1))
        travel_to Date.new(2020, 12, 1) do
          ActionMailer::Base.deliveries.clear
          @ret = RegistrationCost.update_current_period("competitor")
          @ret = RegistrationCost.update_current_period("noncompetitor")
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
        expect(@reg.registrant_expense_items.first.expense_item).to eq(@comp_registration_cost2.expense_item)

        @nc_reg.reload
        expect(@nc_reg.registrant_expense_items.count).to eq(1)
        expect(@nc_reg.registrant_expense_items.first.expense_item).to eq(@noncomp_registration_cost2.expense_item)
      end
    end
  end
end
