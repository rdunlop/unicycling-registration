# == Schema Information
#
# Table name: registrants
#
#  id                       :integer          not null, primary key
#  first_name               :string(255)
#  middle_initial           :string(255)
#  last_name                :string(255)
#  birthday                 :date
#  gender                   :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  user_id                  :integer
#  deleted                  :boolean          default(FALSE), not null
#  bib_number               :integer          not null
#  wheel_size_id            :integer
#  age                      :integer
#  ineligible               :boolean          default(FALSE), not null
#  volunteer                :boolean          default(FALSE), not null
#  online_waiver_signature  :string(255)
#  access_code              :string(255)
#  sorted_last_name         :string(255)
#  status                   :string(255)      default("active"), not null
#  registrant_type          :string(255)      default("competitor")
#  rules_accepted           :boolean          default(FALSE), not null
#  online_waiver_acceptance :boolean          default(FALSE), not null
#  paid                     :boolean          default(FALSE), not null
#
# Indexes
#
#  index_registrants_deleted             (deleted)
#  index_registrants_on_bib_number       (bib_number) UNIQUE
#  index_registrants_on_registrant_type  (registrant_type)
#  index_registrants_on_user_id          (user_id)
#

require 'spec_helper'

describe Registrant do
  before(:each) do
    @reg = FactoryGirl.build(:registrant)
    @ws20 = FactoryGirl.build_stubbed(:wheel_size_20)
    @ws24 = FactoryGirl.build_stubbed(:wheel_size_24)
    allow(WheelSize).to receive(:find_by).with(description: "20\" Wheel").and_return(@ws20)
    allow(WheelSize).to receive(:find_by).with(description: "24\" Wheel").and_return(@ws24)
  end

  describe "with a 10 year old registrant" do
    before(:each) do
      allow(@reg).to receive(:age).and_return(10)
    end

    it "should have a 20\" wheel" do
      @reg.default_wheel_size = nil
      @reg.send(:set_default_wheel_size)
      expect(@reg.default_wheel_size).to eq(@ws20)
    end
  end

  describe "when EventConfiguration does not require default wheel size" do
    let(:registrant) { FactoryGirl.build(:registrant, :competitor, :minor, status: "base_details", contact_detail: nil) }
    before { EventConfiguration.singleton.update(registrants_should_specify_default_wheel_size: false) }

    it "does not set a default wheel size" do
      allow(registrant).to receive(:age).and_return(10)
      expect(registrant).to be_valid
      expect(registrant.default_wheel_size).to be_nil
    end
  end

  describe "with a contact_detail with club, state, country" do
    let(:contact_detail) { FactoryGirl.build(:contact_detail, state_code: "IL", country_representing: "US", club: "My Club") }
    let(:registrant) { FactoryGirl.build(:competitor, contact_detail: contact_detail) }
    let(:subject) { registrant }

    include_context 'can display correct state, country, club', state: "Illinois", country: "United States", club: "My Club"
  end

  describe "with an event configuration starting date" do
    before(:each) do
      EventConfiguration.singleton.update(start_date: Date.new(2012, 5, 20))
    end

    describe "and a registrant born on the starting day in 1982" do
      before(:each) do
        @reg.birthday = Date.new(1982, 5, 20)
        @reg.valid? # set age
      end
      it "should have an age of 30" do
        expect(@reg.age).to eq(30)
      end

      it "should have a wheel_size of 24\"" do
        @reg.send(:set_default_wheel_size)
        expect(@reg.default_wheel_size).to eq(@ws24)
      end
    end

    describe "and a registrant born the day after the starting date in 1982" do
      before(:each) do
        @reg.birthday = Date.new(1982, 5, 21)
        @reg.valid? # set_age
      end
      it "should have an age of 29" do
        expect(@reg.age).to eq(29)
      end

      it "cannot choose a 20\" wheel" do
        @reg.default_wheel_size = @ws20
        @reg.send(:check_default_wheel_size_for_age)
        expect(@reg.errors).not_to be_empty
      end
    end
  end

  context "checking required attributes" do
    before :each do
      @reg.bib_number = nil # clear out the auto-set bib_number
      @reg.valid? # cause bib_number to be set
    end
    it "has a valid reg from FactoryGirl" do
      expect(@reg.valid?).to eq(true)
    end

    it "requires a user" do
      @reg.user = nil
      expect(@reg.valid?).to eq(false)
    end

    it "requires a deleted status" do
      @reg.deleted = nil
      expect(@reg.valid?).to eq(false)
    end

    it "must have a valid registrant_type value" do
      @reg.registrant_type = nil
    end

    it "should be eligible by default" do
      r = Registrant.new
      expect(r.ineligible?).to eq(false)
    end

    it "should not be a volunteer by default" do
      r = Registrant.new
      expect(r.volunteer).to eq(false)
    end

    it "must have a value for ineligible" do
      @reg.ineligible = nil
      expect(@reg.valid?).to eq(false)
    end

    it "requires a birthday" do
      @reg.birthday = nil
      expect(@reg.valid?).to eq(false)
    end

    it "can not have a birthday, while having a configuration" do
      EventConfiguration.singleton.update(start_date: Date.new(2012, 5, 20))
      @reg.birthday = nil
      expect(@reg.valid?).to eq(false)
    end

    it "requires first name" do
      @reg.first_name = nil
      expect(@reg.valid?).to eq(false)
    end

    it "requires last name" do
      @reg.last_name = nil
      expect(@reg.valid?).to eq(false)
    end

    it "requires gender" do
      @reg.gender = nil
      expect(@reg.valid?).to eq(false)
    end

    it "has no paid_line_items" do
      expect(@reg.paid_line_items).to eq([])
    end

    it "has either Male or Female gender" do
      @reg.gender = "Male"
      expect(@reg.valid?).to eq(true)

      @reg.gender = "Female"
      expect(@reg.valid?).to eq(true)

      @reg.gender = "Other"
      expect(@reg.valid?).to eq(false)
    end

    it "defaults the deleted flag to false" do
      reg = Registrant.new
      expect(reg.deleted).to eq(false)
    end

    it "has a to_s" do
      expect(@reg.to_s).to eq(@reg.first_name + " " + @reg.last_name)
    end

    it "has a name field" do
      expect(@reg.name).to eq(@reg.first_name + " " + @reg.last_name)
    end

    it "bib_number is set to 1 as a competitor" do
      expect(@reg.bib_number).to eq(1)
    end
  end

  context "checking non-competitor default" do
    it "bib_number is set to 2001 as a non-competitor" do
      @nreg = FactoryGirl.build(:noncompetitor)
      @nreg.bib_number = nil # clear out auto-set bib number
      @nreg.valid? # cause bib_number to be set
      expect(@nreg.bib_number).to eq(2001)
    end
  end

  context "associations" do
    it "has an owing cost of 0 by default" do
      expect(@reg.amount_owing).to eq(0.to_money)
    end
    it "always displays the expenses_total" do
      expect(@reg.expenses_total).to eq(0.to_money)
    end
  end
end

describe Registrant do
  before(:each) do
    @reg = FactoryGirl.create(:competitor)
  end

  it "has a valid reg from FactoryGirl" do
    expect(@reg.valid?).to eq(true)
  end

  it "has an access_code" do
    expect(@reg.access_code).to_not be_empty
  end

  describe "with a deleted competitor" do
    before(:each) do
      @reg.deleted = true
      @reg.save!
    end
    it "can build a competitor" do
      @reg2 = FactoryGirl.create(:competitor)
      expect(@reg2.external_id).to eq(2)
    end

    it "cannot have the same bib_number" do
      @reg2 = FactoryGirl.build(:competitor, bib_number: @reg.bib_number)
      expect(@reg2).to be_invalid
    end
  end

  describe "with an expense_item" do
    before(:each) do
      @item = FactoryGirl.create(:expense_item)
      @rei = FactoryGirl.build(:registrant_expense_item, registrant: @reg, line_item: @item)
      @reg.registrant_expense_items << @rei
      @rei.save
      @reg.reload
    end

    it "has expense_items" do
      expect(@reg.registrant_expense_items).to eq([@rei])
      expect(@reg.expense_items).to eq([@item])
    end
    it "describes the expense_total as the sum" do
      expect(@reg.expenses_total).to eq(@item.cost)
    end
    it "lists the item as an owing_expense_item" do
      expect(@reg.owing_line_items).to eq([@item])
      expect(@reg.owing_registrant_expense_items.first).to eq(@rei)
    end

    describe "having paid for the item once, but still having it as a registrant_expense_item" do
      before(:each) do
        @payment = FactoryGirl.create(:payment)
        @payment_detail = FactoryGirl.create(:payment_detail, payment: @payment, registrant: @reg, amount: @item.cost, line_item: @item)
        @payment.reload
        @payment.completed = true
        @payment.save!

        rei = FactoryGirl.build(:registrant_expense_item, registrant: @reg, line_item: @item)
        @reg.registrant_expense_items << rei
        rei.save
        @reg.reload
      end
      it "lists one remaining item as owing" do
        expect(@reg.owing_line_items).to eq([@item])
      end
      it "lists the item as paid for" do
        expect(@reg.paid_line_items).to eq([@item])
      end
      it "should list the item twice in the all_line_items" do
        expect(@reg.all_line_items).to eq([@item, @item])
      end
    end
  end

  describe "with a registrant_choice" do
    before(:each) do
      @rc = FactoryGirl.create(:registrant_choice, registrant: @reg)
      @reg.reload
    end
    it "can access its registrant choices" do
      expect(@reg.registrant_choices).to eq([@rc])
    end
    it "can access the event_choices" do
      expect(@reg.event_choices).to eq([@rc.event_choice])
    end
    it "can access the events" do
      expect(@reg.events).to eq([@rc.event_choice.event])
    end
    it "can access the categories" do
      expect(@reg.categories).to eq([@rc.event_choice.event.category])
    end
    it "Destroys the related registrant_choice upon destroy" do
      expect(RegistrantChoice.all.count).to eq(1)
      @reg.destroy
      expect(RegistrantChoice.all.count).to eq(0)
    end
  end

  describe "with a registrant best time" do
    let(:event) { FactoryGirl.create :event, :marathon_best_time_format }
    let(:registrant_best_time) { FactoryGirl.create(:registrant_best_time, event: event, registrant: @reg, formatted_value: "12:30", source_location: "NAUCC 2014") }

    it "has the correct output of registrant describe_event_hash" do
      the_hash = @reg.reload.describe_event_hash(registrant_best_time.event)
      expect(the_hash[:additional]).to eq("Best Time: 12:30 @ NAUCC 2014")
    end
  end

  describe "with a standard_skill registrant_choice" do
    before(:each) do
      event = FactoryGirl.create(:event, name: "Standard Skill", standard_skill: true)
      event_category = event.event_categories.first
      @rc = FactoryGirl.create(:registrant_event_sign_up, event: event, event_category: event_category, registrant: @reg, signed_up: true)
      @reg.reload
    end
    it "should list as having standard skill" do
      expect(@reg.has_standard_skill?).to eq(true)
    end
    it "should not list if not selected" do
      @rc.signed_up = false
      @rc.save!
      expect(@reg.has_standard_skill?).to eq(false)
    end
  end

  describe "with a registration_cost" do
    before(:each) do
      @comp_exp = FactoryGirl.create(:expense_item, cost: 100)
      @noncomp_exp = FactoryGirl.create(:expense_item, cost: 50)
      @comp_reg_cost = FactoryGirl.create(:registration_cost, :competitor, start_date: Date.new(2010, 1, 1), end_date: Date.new(2022, 1, 1), expense_item: @comp_exp)
      @noncomp_reg_cost = FactoryGirl.create(:registration_cost, :noncompetitor, start_date: Date.new(2010, 1, 1), end_date: Date.new(2022, 1, 1), expense_item: @noncomp_exp)
    end

    describe "with an older (PAID_FOR) registration_cost" do
      before(:each) do
        @oldcomp_exp = FactoryGirl.create(:expense_item, cost: 90)
        @oldnoncomp_exp = FactoryGirl.create(:expense_item, cost: 40)
        @comp_reg_cost = FactoryGirl.create(:registration_cost, :competitor, start_date: Date.new(2009, 1, 1), end_date: Date.new(2010, 1, 1),
                                                                             expense_item: @oldcomp_exp)
        @noncomp_reg_cost = FactoryGirl.create(:registration_cost, :noncompetitor, start_date: Date.new(2009, 1, 1), end_date: Date.new(2010, 1, 1),
                                                                                   expense_item: @oldnoncomp_exp)
        @comp = FactoryGirl.create(:competitor)
        @payment = FactoryGirl.create(:payment)
        @payment_detail = FactoryGirl.create(:payment_detail, payment: @payment, registrant: @comp, amount: 90, line_item: @oldcomp_exp)
        @payment.reload
        @payment.completed = true
        @payment.save
        @comp.reload
      end
      it "should return nil as the registration_item" do
        expect(@comp.registrant_expense_items.count).to eq(0)
      end
      it "should not allow deleting the registrant" do
        @comp.deleted = true
        expect(@comp.valid?).to eq(false)
      end
    end

    describe "with a completed payment" do
      before(:each) do
        @comp = FactoryGirl.create(:competitor)
        @payment = FactoryGirl.create(:payment)
        @payment_detail = FactoryGirl.create(:payment_detail, payment: @payment, registrant: @comp, amount: 100, line_item: @comp_exp)
        @payment.reload
        @payment.completed = true
        @payment.save
        @comp.reload
      end
      it "should have associated payment_details" do
        expect(@comp.payment_details).to eq([@payment_detail])
      end
      it "should have an amount_paid" do
        expect(@comp.amount_paid).to eq(100.to_money)
      end
      it "should owe 0" do
        expect(@comp.amount_owing).to eq(0.to_money)
      end
      it "lists the paid_line_items" do
        expect(@comp.paid_line_items).to eq([@payment_detail.line_item])
      end
      it "lists no items as an owing_expense_item" do
        expect(@comp.owing_line_items).to eq([])
      end
      it "knows that the registration_fee has been paid" do
        expect(@comp.reg_paid?).to eq(true)
      end

      it "lists the payment_detail as a paid_detail" do
        expect(@comp.paid_details).to eq([@payment_detail])
      end

      describe "with a refund of everything it has completed" do
        before(:each) do
          @ref_det = FactoryGirl.create(:refund_detail, payment_detail: @payment_detail)
        end

        it "lists nothing as paid" do
          expect(@comp.paid_details).to eq([])
          expect(@comp.payment_details.count).to eq(1)
        end

        it "no longer lists the registration as paid" do
          expect(@comp.reg_paid?).to eq(false)
        end

        it "can delete the registrant" do
          @comp.deleted = true
          expect(@comp.valid?).to eq(true)
        end
      end
    end

    describe "with an incomplete payment" do
      before(:each) do
        @comp = FactoryGirl.create(:competitor)
        @payment = FactoryGirl.create(:payment)
        @payment_detail = FactoryGirl.create(:payment_detail, payment: @payment, registrant: @comp, amount: 100, line_item: @comp_exp)
      end
      it "should have associated payment_details" do
        expect(@comp.payment_details).to eq([@payment_detail])
      end
      it "should not have an amount_paid" do
        expect(@comp.amount_paid).to eq(0.to_money)
      end
      it "should owe 100" do
        expect(@comp.amount_owing).to eq(100.to_money)
      end
      it "lists the paid_line_items" do
        expect(@comp.paid_line_items).to eq([])
      end
      it "lists no items as an owing_expense_item" do
        expect(@comp.owing_line_items).to eq([@comp_exp])
      end
      it "knows that the registration_fee has NOT been paid" do
        expect(@comp.reg_paid?).to eq(false)
      end
    end
  end

  describe "with an expense_group which REQUIRES one free item per group" do
    before(:each) do
      @eg = FactoryGirl.create(:expense_group)
      FactoryGirl.create(:expense_group_free_option, expense_group: @eg, registrant_type: "competitor", free_option: "One Free In Group REQUIRED")
      @ei = FactoryGirl.create(:expense_item, expense_group: @eg)
    end

    it "is invalid without the item" do
      expect(@reg).to be_invalid
    end

    context "when it has the (free) expense item" do
      before(:each) do
        FactoryGirl.create(:registrant_expense_item, registrant: @reg, line_item: @ei, free: true)
        @reg.reload
      end

      it "is valid" do
        expect(@reg).to be_valid
      end
    end
  end

  describe "with an expense_group marked as 'required' created AFTER the non-competitor registrant" do
    before(:each) do
      @nc_reg = FactoryGirl.create(:noncompetitor)
      @eg = FactoryGirl.create(:expense_group, noncompetitor_required: true)
      @ei = FactoryGirl.create(:expense_item, expense_group: @eg)
    end

    it "should include this expense_item in the list of owing_registrant_expense_items" do
      @reg.reload
      expect(@reg.owing_registrant_expense_items.count).to eq(0)
      @nc_reg.reload
      expect(@nc_reg.owing_registrant_expense_items.count).to eq(1)
      expect(@nc_reg.owing_registrant_expense_items.last.system_managed).to eq(true)
    end
  end

  describe "with an expense_group marked as 'required' created AFTER the registrant" do
    before(:each) do
      @eg = FactoryGirl.create(:expense_group, competitor_required: true)
      @ei = FactoryGirl.create(:expense_item, expense_group: @eg)
    end

    it "should include this expense_item in the list of owing_registrant_expense_items" do
      @reg.reload
      expect(@reg.owing_registrant_expense_items.last.line_item).to eq(@ei)
      expect(@reg.owing_registrant_expense_items.last.system_managed).to eq(true)
    end
  end

  describe "with an expense_group marked as 'required' created BEFORE the registrant" do
    before(:each) do
      @eg = FactoryGirl.create(:expense_group, competitor_required: true)
      @ei = FactoryGirl.create(:expense_item, expense_group: @eg)
      @reg2 = FactoryGirl.create(:competitor)
    end

    it "should include this expense_item in the list of owing_registrant_expense_items" do
      expect(@reg2.owing_registrant_expense_items.last.line_item).to eq(@ei)
      expect(@reg2.owing_registrant_expense_items.last.system_managed).to eq(true)
    end

    describe "when it has paid for the expense_item" do
      before(:each) do
        @payment = FactoryGirl.create(:payment)
        @payment_detail = FactoryGirl.create(:payment_detail, payment: @payment, registrant: @reg2, amount: @ei.cost, line_item: @ei)
        @payment.reload
        @payment.completed = true
        @payment.save!
        @reg2.reload
      end

      it "no longer has the item as owing" do
        expect(@reg2.owing_registrant_expense_items.count).to eq(0)
      end
    end
  end
end
