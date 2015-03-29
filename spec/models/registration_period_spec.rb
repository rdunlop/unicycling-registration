# == Schema Information
#
# Table name: registration_periods
#
#  id                            :integer          not null, primary key
#  start_date                    :date
#  end_date                      :date
#  created_at                    :datetime
#  updated_at                    :datetime
#  competitor_expense_item_id    :integer
#  noncompetitor_expense_item_id :integer
#  onsite                        :boolean          default(FALSE), not null
#  current_period                :boolean          default(FALSE), not null
#

require 'spec_helper'

describe RegistrationPeriod do
  before(:each) do
    @rp = FactoryGirl.create(:registration_period, :start_date => Date.new(2012, 11, 03), :end_date => Date.new(2012, 11, 07))
  end

  it "is valid from FactoryGirl" do
    expect(@rp.valid?).to eq(true)
  end

  it "must have a start date" do
    @rp.start_date = nil
    expect(@rp.valid?).to eq(false)
  end

  it "must have an end date" do
    @rp.end_date = nil
    expect(@rp.valid?).to eq(false)
  end

  it "must have a competitor_expense_item" do
    @rp.competitor_expense_item = nil
    expect(@rp.valid?).to eq(false)
  end

  it "must have a noncompetitor_expense_item" do
    @rp.noncompetitor_expense_item = nil
    expect(@rp.valid?).to eq(false)
  end

  it "must have onsite set" do
    @rp.onsite = nil
    expect(@rp.valid?).to eq(false)
  end

  it "is not onsite by default" do
    rp = RegistrationPeriod.new
    expect(rp.onsite).to eq(false)
  end

  it "can determine the last online registration period" do
    expect(RegistrationPeriod.last_online_period).to eq(@rp)
  end

  describe "with associated expense_items" do
    let!(:comp_item) { @rp.competitor_expense_item }
    let!(:noncomp_item) { @rp.noncompetitor_expense_item }

    it "removes the expense item on RP deletion" do
      @rp.destroy
      expect(comp_item).to be_destroyed
      expect(noncomp_item).to be_destroyed
    end

    describe "when the expense_item has a payment" do
      before do
        FactoryGirl.create :payment_detail, expense_item: comp_item
      end

      it "can't remove the RP on deletion" do
        expect { @rp.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
      end
    end
  end

  describe "with existing periods" do
    before(:each) do
      @rp1 = FactoryGirl.create(:registration_period, :start_date => Date.new(2012, 01, 01), :end_date => Date.new(2012, 02, 02))
      @rp2 = FactoryGirl.create(:registration_period, :start_date => Date.new(2012, 02, 03), :end_date => Date.new(2012, 04, 04))
    end

    it "can retrieve period" do
      expect(RegistrationPeriod.relevant_period(Date.new(2012, 01, 15))).to eq(@rp1)
    end

    it "gets nil for missing section" do
      expect(RegistrationPeriod.relevant_period(Date.new(2010, 01, 01))).to be_nil
    end

    it "returns the first registration period INCLUDING the day AFTER the period ends" do
      expect(RegistrationPeriod.relevant_period(Date.new(2012, 02, 03))).to eq(@rp1)
    end

    it "returns the second registration period +2 days after the first period ends" do
      expect(RegistrationPeriod.relevant_period(Date.new(2012, 02, 04))).to eq(@rp2)
    end

    it "disregards onsite registration periods for last_online_period" do
      @rp.onsite = true
      @rp.save!
      expect(RegistrationPeriod.last_online_period).to eq(@rp2)
    end
    describe "with more registration periods" do
      before(:each) do
        @rp0 = FactoryGirl.create(:registration_period, :start_date => Date.new(2010, 02, 03), :end_date => Date.new(2010, 04, 04))
      end
      it "returns the periods in ascending date order" do
        expect(RegistrationPeriod.all).to eq([@rp0, @rp1, @rp2, @rp])
      end
    end

    describe "when searching for a paid-for registration period" do
      it "can retrieve the matching registration_period" do
        expect(RegistrationPeriod.paid_for_period(true, [])).to be_nil
      end
      it "can retrieve a matching competitor period" do
        expect(RegistrationPeriod.paid_for_period(true, [@rp1.competitor_expense_item])).to eq(@rp1)
        expect(RegistrationPeriod.paid_for_period(true, [@rp2.competitor_expense_item])).to eq(@rp2)
      end
      it "can retrieve a matching noncompetitor period" do
        expect(RegistrationPeriod.paid_for_period(false, [@rp1.noncompetitor_expense_item])).to eq(@rp1)
        expect(RegistrationPeriod.paid_for_period(false, [@rp2.noncompetitor_expense_item])).to eq(@rp2)
      end
    end

    it "can identify the current period" do
      expect(@rp1.current_period?(Date.new(2012, 01, 14))).to eq(true)
      expect(@rp2.current_period?(Date.new(2012, 01, 14))).to eq(false)
    end
    it "can identify past periods" do
      expect(@rp1.past_period?(Date.new(2012, 02, 20))).to eq(true)
      expect(@rp2.past_period?(Date.new(2012, 02, 20))).to eq(false)
    end
  end
end
describe "when testing the update function for registration periods", :caching => true do
  before(:each) do
    # create a rp which encompasses "today"
    @rp1 = FactoryGirl.create(:registration_period, :start_date => Date.new(2012, 12, 21), :end_date => Date.new(2020, 11, 7))
    @reg = FactoryGirl.create(:competitor) # will have rp1
    @nc_reg = FactoryGirl.create(:noncompetitor) # will have rp1
  end
  it "initially doesn't have a current_period" do
    expect(RegistrationPeriod.current_period).to be_nil
  end
  it "initially says that no update has been (yet) performed" do
    expect(RegistrationPeriod.update_checked_recently).to eq(false)
  end

  it "initially, the registrant has an expense_item from the current period" do
    expect(@reg.registrant_expense_items.count).to eq(1)
    expect(@reg.registrant_expense_items.first.expense_item).to eq(@rp1.competitor_expense_item)
    expect(@nc_reg.registrant_expense_items.count).to eq(1)
    expect(@nc_reg.registrant_expense_items.first.expense_item).to eq(@rp1.noncompetitor_expense_item)
  end

  describe "after the update has been called" do
    before(:each) do
      ActionMailer::Base.deliveries.clear
      RegistrationPeriod.update_current_period(Date.new(2012, 12, 22))
    end
    it "sets the current period when invoked" do
      expect(RegistrationPeriod.current_period).to eq(@rp1)
    end

    it "says that an update has been performed recently" do
      expect(RegistrationPeriod.update_checked_recently(Date.new(2012, 12, 22))).to eq(true)
    end

    it "(when looking 3 days in the future) says that an update has not yet been done" do
      expect(RegistrationPeriod.update_checked_recently(Date.new(2012, 12, 25))).to eq(false)
    end

    it "sends an e-mail when it changes the reg period" do
      num_deliveries = ActionMailer::Base.deliveries.size
      expect(num_deliveries).to eq(1)
    end

    describe "when a registrant has a LOCKED registration_item" do
      before(:each) do
        @original_item = rei = @reg.registration_item
        rei.locked = true
        rei.save
      end

      it "doesnt't update this registrants' items when moving to the next period" do
        @rp2 = FactoryGirl.create(:registration_period, :start_date => Date.new(2020, 11, 8), :end_date => Date.new(2021, 1, 1))
        @ret = RegistrationPeriod.update_current_period(Date.new(2020, 12, 1))
        @reg.reload
        expect(@reg.registration_item).to eq(@original_item)
      end
    end
    describe "when updating to the next period" do
      before(:each) do
        ActionMailer::Base.deliveries.clear
        @rp2 = FactoryGirl.create(:registration_period, :start_date => Date.new(2020, 11, 8), :end_date => Date.new(2021, 1, 1))
        @ret = RegistrationPeriod.update_current_period(Date.new(2020, 12, 1))
      end

      it "it indicates that the new period has been recently updated" do
        expect(RegistrationPeriod.update_checked_recently(Date.new(2020, 12, 2))).to eq(true)
      end
      it "indicates that it updated" do
        expect(@ret).to eq(true)
      end
      it "updates the current_period" do
        expect(RegistrationPeriod.current_period).to eq(@rp2)
      end
      it "sends an e-mail when it changes the reg period" do
        num_deliveries = ActionMailer::Base.deliveries.size
        expect(num_deliveries).to eq(1)
        email = ActionMailer::Base.deliveries.first
        expect(email.subject).to eq("Updated Registration Period")
      end
      it "changes the registrant's item to the new period" do
        @reg.reload
        expect(@reg.registrant_expense_items.count).to eq(1)
        expect(@reg.registrant_expense_items.first.expense_item).to eq(@rp2.competitor_expense_item)

        @nc_reg.reload
        expect(@nc_reg.registrant_expense_items.count).to eq(1)
        expect(@nc_reg.registrant_expense_items.first.expense_item).to eq(@rp2.noncompetitor_expense_item)
      end
    end
    describe "when updating to a non-existent period" do
      before(:each) do
        ActionMailer::Base.deliveries.clear
        @ret = RegistrationPeriod.update_current_period(Date.new(2020, 12, 1))
      end

      it "indicates that it updated" do
        expect(@ret).to eq(true)
      end
      it "updates the current_period (which is nil)" do
        expect(RegistrationPeriod.current_period).to be_nil
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
          ActionMailer::Base.deliveries.clear
          @rp2 = FactoryGirl.create(:registration_period, :start_date => Date.new(2020, 11, 8), :end_date => Date.new(2021, 1, 1))
          @ret = RegistrationPeriod.update_current_period(Date.new(2020, 12, 1))
        end

        it "indicates that it updated" do
          expect(@ret).to eq(true)
        end
        it "updates the current_period" do
          expect(RegistrationPeriod.current_period).to eq(@rp2)
        end
        it "sends an e-mail when it changes the reg period" do
          num_deliveries = ActionMailer::Base.deliveries.size
          expect(num_deliveries).to eq(1)
          email = ActionMailer::Base.deliveries.first
          expect(email.subject).to eq("Updated Registration Period")
        end
        it "changes the registrant's item to the new period" do
          @reg.reload
          expect(@reg.registrant_expense_items.count).to eq(1)
          expect(@reg.registrant_expense_items.first.expense_item).to eq(@rp2.competitor_expense_item)

          @nc_reg.reload
          expect(@nc_reg.registrant_expense_items.count).to eq(1)
          expect(@nc_reg.registrant_expense_items.first.expense_item).to eq(@rp2.noncompetitor_expense_item)
        end
      end
    end
  end
end
