# == Schema Information
#
# Table name: registrants
#
#  id                      :integer          not null, primary key
#  first_name              :string(255)
#  middle_initial          :string(255)
#  last_name               :string(255)
#  birthday                :date
#  gender                  :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  user_id                 :integer
#  deleted                 :boolean
#  bib_number              :integer
#  wheel_size_id           :integer
#  age                     :integer
#  ineligible              :boolean          default(FALSE)
#  volunteer               :boolean
#  online_waiver_signature :string(255)
#  access_code             :string(255)
#  sorted_last_name        :string(255)
#  status                  :string(255)      default("active"), not null
#  registrant_type         :string(255)      default("competitor")
#
# Indexes
#
#  index_registrants_deleted             (deleted)
#  index_registrants_on_registrant_type  (registrant_type)
#  index_registrants_on_user_id          (user_id)
#

require 'spec_helper'

describe Registrant do
  before(:each) do
    @reg = FactoryGirl.build_stubbed(:registrant)
    @ws20 = FactoryGirl.build_stubbed(:wheel_size_20)
    @ws24 = FactoryGirl.build_stubbed(:wheel_size_24)
    allow(WheelSize).to receive(:find_by_description).with("20\" Wheel").and_return(@ws20)
    allow(WheelSize).to receive(:find_by_description).with("24\" Wheel").and_return(@ws24)
    allow(Registrant).to receive(:maximum_bib_number).and_return(nil)
  end

  describe "with a 10 year old registrant" do
    before(:each) do
      allow(@reg).to receive(:age).and_return(10)
    end

    it "should have a 20\" wheel" do
      @reg.default_wheel_size = nil
      @reg.set_default_wheel_size
      @reg.default_wheel_size.should == @ws20
    end
  end

  describe "with an event configuration starting date" do
    before(:each) do
      FactoryGirl.create(:event_configuration, start_date: Date.new(2012, 05, 20))
    end

    describe "and a registrant born on the starting day in 1982" do
      before(:each) do
        @reg.birthday = Date.new(1982, 05, 20)
        @reg.set_age
      end
      it "should have an age of 30" do
        @reg.age.should == 30
      end

      it "should have a wheel_size of 24\"" do
        @reg.set_default_wheel_size
        @reg.default_wheel_size.should == @ws24
      end
    end

    describe "and a registrant born the day after the starting date in 1982" do
      before(:each) do
        @reg.birthday = Date.new(1982, 05, 21)
        @reg.set_age
      end
      it "should have an age of 29" do
        @reg.age.should == 29
      end

      it "cannot choose a 20\" wheel" do
        @reg.default_wheel_size = @ws20
        @reg.check_default_wheel_size_for_age
        @reg.errors.should_not be_empty
      end
    end
  end

  context "checking required attributes" do
    before :each do
      @reg.bib_number = nil # clear out the auto-set bib_number
      @reg.set_bib_number
    end
    it "has a valid reg from FactoryGirl" do
      @reg.valid?.should == true
    end

    it "requires a user" do
      @reg.user = nil
      @reg.valid?.should == false
    end

    it "requires a deleted status" do
      @reg.deleted = nil
      @reg.valid?.should == false
    end

    it "must have a valid registrant_type value" do
      @reg.registrant_type = nil
    end

    it "should be eligible by default" do
      r = Registrant.new
      r.ineligible.should == false
    end

    it "should not be a volunteer by default" do
      r = Registrant.new
      r.volunteer.should == false
    end

    it "must have a value for ineligible" do
      @reg.ineligible = nil
      @reg.valid?.should == false
    end

    it "requires an bib_number" do
      @reg.bib_number = nil
      @reg.valid?.should == false
    end

    it "requires a birthday" do
      @reg.birthday = nil
      @reg.valid?.should == false
    end

    it "can not have a birthday, while having a configuration" do
      FactoryGirl.create(:event_configuration, start_date: Date.new(2012, 05, 20))
      @reg.birthday = nil
      @reg.valid?.should == false
    end

    it "requires first name" do
      @reg.first_name = nil
      @reg.valid?.should == false
    end

    it "requires last name" do
      @reg.last_name = nil
      @reg.valid?.should == false
    end

    it "requires gender" do
      @reg.gender = nil
      @reg.valid?.should == false
    end

    it "has no paid_expense_items" do
      @reg.paid_expense_items.should == []
    end

    it "has either Male or Female gender" do
      @reg.gender = "Male"
      @reg.valid?.should == true

      @reg.gender = "Female"
      @reg.valid?.should == true

      @reg.gender = "Other"
      @reg.valid?.should == false
    end

    it "defaults the deleted flag to false" do
      reg = Registrant.new
      reg.deleted.should == false
    end

    it "has a to_s" do
      @reg.to_s.should == @reg.first_name + " " + @reg.last_name
    end

    it "has a name field" do
      @reg.name.should == @reg.first_name + " " + @reg.last_name
    end

    it "bib_number is set to 1 as a competitor" do
      @reg.bib_number.should == 1
    end
    describe "with a second competitor" do
      before(:each) do
        allow(Registrant).to receive(:maximum_bib_number).and_return(1)
      end
      it "assigns the second competitor bib_number 2" do
        @reg2 = FactoryGirl.build_stubbed(:competitor)
        @reg2.bib_number = nil # clear out the auto-set bib_number
        @reg2.set_bib_number
        @reg2.bib_number.should == 2
      end
    end
  end

  context "checking non-competitor default" do
    it "bib_number is set to 2001 as a non-competitor" do
      @nreg = FactoryGirl.build_stubbed(:noncompetitor)
      @nreg.bib_number = nil # clear out auto-set bib number
      @nreg.set_bib_number
      @nreg.bib_number.should == 2001
    end

    describe "with a second non-competitor" do
      before :each do
        allow(Registrant).to receive(:maximum_bib_number).and_return(2001)
      end
      it "assigns the second noncompetitor bib_number 2002" do
        @reg2 = FactoryGirl.build_stubbed(:noncompetitor)
        @reg2.bib_number = nil # clear out auto-set bib number
        @reg2.set_bib_number
        @reg2.bib_number.should == 2002
      end
    end
  end

  context "associations" do
    it "has an owing cost of 0 by default" do
      @reg.amount_owing.should == 0
    end
    it "always displays the expenses_total" do
      @reg.expenses_total.should == 0
    end
  end
end

describe Registrant do
  before(:each) do
    @reg = FactoryGirl.create(:competitor)
  end

  it "has a valid reg from FactoryGirl" do
    @reg.valid?.should == true
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
      @reg2.external_id.should == 2
    end
  end

  describe "with an expense_item" do
    before(:each) do
      @item = FactoryGirl.create(:expense_item)
      @rei = FactoryGirl.build(:registrant_expense_item, :registrant => @reg, :expense_item => @item)
      @reg.registrant_expense_items << @rei
      @rei.save
      @reg.reload
    end

    it "has expense_items" do
      @reg.registrant_expense_items.should == [@rei]
      @reg.expense_items.should == [@item]
    end
    it "describes the expense_total as the sum" do
      @reg.expenses_total.should == @item.cost
    end
    it "lists the item as an owing_expense_item" do
      @reg.owing_expense_items.should == [@item]
      @reg.owing_registrant_expense_items.first.should == @rei
    end
    it "lists no details for its items" do
      @reg.owing_expense_items_with_details.should == [[@item, nil]]
    end

    describe "With an expense_item having text details" do
      before(:each) do
        @rei.details = "These are some details"
        @rei.save!
        @reg.reload
      end

      it "should transfer the text along" do
        @reg.owing_expense_items_with_details.should == [[@item, "These are some details"]]
      end
    end

    describe "having paid for the item once, but still having it as a registrant_expense_item" do
      before(:each) do
        @payment = FactoryGirl.create(:payment)
        @payment_detail = FactoryGirl.create(:payment_detail, :payment => @payment, :registrant => @reg, :amount => @item.cost, :expense_item => @item)
        @payment.reload
        @payment.completed = true
        @payment.save!

        rei = FactoryGirl.build(:registrant_expense_item, :registrant => @reg, :expense_item => @item)
        @reg.registrant_expense_items << rei
        rei.save
        @reg.reload
      end
      it "lists one remaining item as owing" do
        @reg.owing_expense_items.should == [@item]
      end
      it "lists the item as paid for" do
        @reg.paid_expense_items.should == [@item]
      end
      it "should list the item twice in the all_expense_items" do
        @reg.all_expense_items.should == [@item, @item]
      end
    end
  end

  describe "with a registrant_choice" do
    before(:each) do
      @rc = FactoryGirl.create(:registrant_choice, :registrant => @reg)
      @reg.reload
    end
    it "can access its registrant choices" do
      @reg.registrant_choices.should == [@rc]
    end
    it "can access the event_choices" do
      @reg.event_choices.should == [@rc.event_choice]
    end
    it "can access the events" do
      @reg.events.should == [@rc.event_choice.event]
    end
    it "can access the categories" do
      @reg.categories.should == [@rc.event_choice.event.category]
    end
    it "Destroys the related registrant_choice upon destroy" do
      RegistrantChoice.all.count.should == 1
      @reg.destroy
      RegistrantChoice.all.count.should == 0
    end
  end
  describe "with a standard_skill registrant_choice" do
    before(:each) do
      event = FactoryGirl.create(:event, :name => "Standard Skill")
      event_category = event.event_categories.first
      @rc = FactoryGirl.create(:registrant_event_sign_up, :event => event, :event_category => event_category, :registrant => @reg, :signed_up => true)
      @reg.reload
    end
    it "should list as having standard skill" do
      @reg.has_standard_skill?.should == true
    end
    it "should not list if not selected" do
      @rc.signed_up = false
      @rc.save!
      @reg.has_standard_skill?.should == false
    end
  end

  describe "with a registration_period" do
    before(:each) do
      @comp_exp = FactoryGirl.create(:expense_item, :cost => 100)
      @noncomp_exp = FactoryGirl.create(:expense_item, :cost => 50)
      @rp = FactoryGirl.create(:registration_period, :start_date => Date.new(2010, 01, 01), :end_date => Date.new(2022, 01, 01), :competitor_expense_item => @comp_exp, :noncompetitor_expense_item => @noncomp_exp)
    end

    describe "with an older (PAID_FOR) registration_period" do
      before(:each) do
        @oldcomp_exp = FactoryGirl.create(:expense_item, :cost => 90)
        @oldnoncomp_exp = FactoryGirl.create(:expense_item, :cost => 40)
        @rp = FactoryGirl.create(:registration_period, :start_date => Date.new(2009, 01, 01), :end_date => Date.new(2010, 01, 01),
                                                       :competitor_expense_item => @oldcomp_exp, :noncompetitor_expense_item => @oldnoncomp_exp)
        @comp = FactoryGirl.create(:competitor)
        @payment = FactoryGirl.create(:payment)
        @payment_detail = FactoryGirl.create(:payment_detail, :payment => @payment, :registrant => @comp, :amount => 90, :expense_item => @oldcomp_exp)
        @payment.reload
        @payment.completed = true
        @payment.save
        @comp.reload
      end
      it "should return nil as the registration_item" do
        @comp.registrant_expense_items.count.should == 0
      end
      it "should not allow deleting the registrant" do
        @comp.deleted = true
        @comp.valid?.should == false
      end
    end

    describe "with a completed payment" do
      before(:each) do
        @comp = FactoryGirl.create(:competitor)
        @payment = FactoryGirl.create(:payment)
        @payment_detail = FactoryGirl.create(:payment_detail, :payment => @payment, :registrant => @comp, :amount => 100, :expense_item => @comp_exp)
        @payment.reload
        @payment.completed = true
        @payment.save
        @comp.reload
      end
      it "should have associated payment_details" do
        @comp.payment_details.should == [@payment_detail]
      end
      it "should have an amount_paid" do
        @comp.amount_paid.should == 100
      end
      it "should owe 0" do
        @comp.amount_owing.should == 0
      end
      it "lists the paid_expense_items" do
        @comp.paid_expense_items.should == [@payment_detail.expense_item]
      end
      it "lists no items as an owing_expense_item" do
        @comp.owing_expense_items.should == []
      end
      it "knows that the registration_fee has been paid" do
        @comp.reg_paid?.should == true
      end

      it "lists the payment_detail as a paid_detail" do
        @comp.paid_details.should == [@payment_detail]
      end

      describe "with a refund of everything it has completed" do
        before(:each) do
          @ref_det = FactoryGirl.create(:refund_detail, :payment_detail => @payment_detail)
        end

        it "lists nothing as paid" do
          @comp.paid_details.should == []
          @comp.payment_details.count.should == 1
        end

        it "no longer lists the registration as paid" do
          @comp.reg_paid?.should == false
        end

        it "can delete the registrant" do
          @comp.deleted = true
          @comp.valid?.should == true
        end
      end
    end

    describe "with an incomplete payment" do
      before(:each) do
        @comp = FactoryGirl.create(:competitor)
        @payment = FactoryGirl.create(:payment)
        @payment_detail = FactoryGirl.create(:payment_detail, :payment => @payment, :registrant => @comp, :amount => 100, :expense_item => @comp_exp)
      end
      it "should have associated payment_details" do
        @comp.payment_details.should == [@payment_detail]
      end
      it "should not have an amount_paid" do
        @comp.amount_paid.should == 0
      end
      it "should owe 100" do
        @comp.amount_owing.should == 100
      end
      it "lists the paid_expense_items" do
        @comp.paid_expense_items.should == []
      end
      it "lists no items as an owing_expense_item" do
        @comp.owing_expense_items.should == [@comp_exp]
      end
      it "knows that the registration_fee has NOT been paid" do
        @comp.reg_paid?.should == false
      end
    end
  end

  describe "with an expense_group which allows one free item per group" do
    before(:each) do
      @eg = FactoryGirl.create(:expense_group, :competitor_free_options => "One Free In Group")
      @ei = FactoryGirl.create(:expense_item, :expense_group => @eg)
    end

    it "marks the registrant as expense_item_is_free for this expense_item" do
      @reg.expense_item_is_free(@ei).should == true
    end
    describe "when it has a non-free item of the same expense_group (not free though)" do
      before(:each) do
        FactoryGirl.create(:registrant_expense_item, :registrant => @reg, :expense_item => @ei)
        @reg.reload
      end

      it "shows that a free item is available" do
        @reg.expense_item_is_free(@ei).should == true
      end
    end

    describe "when it has a free expense_item" do
      before(:each) do
        FactoryGirl.create(:registrant_expense_item, :registrant => @reg, :expense_item => @ei, :free => true)
        @reg.reload
      end

      it "doesn't allow registrant to have 2 free of this group" do
        @rei = FactoryGirl.build(:registrant_expense_item, :registrant => @reg, :expense_item => @ei, :free => true)
        @rei.valid?.should == false
      end

      it "shows that it has the given expense_group" do
        @reg.has_chosen_free_item_from_expense_group(@eg).should == true
      end
    end

    describe "when it has a paid expense_item" do
      before(:each) do
        @ei = FactoryGirl.create(:expense_item, :expense_group => @eg)
        @pay = FactoryGirl.create(:payment)
        @pei = FactoryGirl.create(:payment_detail, :registrant => @reg, :payment => @pay, :expense_item => @ei, :free => true)
        @pay.reload
        @pay.completed = true
        @pay.save!
        @reg.reload
      end

      it "shows that it has the given expense_group" do
        @reg.has_chosen_free_item_from_expense_group(@eg).should == true
      end
    end
  end

  describe "with an expense_group which allows one free item per item in group" do
    before(:each) do
      @eg = FactoryGirl.create(:expense_group, :competitor_free_options => "One Free of Each In Group")
      @ei = FactoryGirl.create(:expense_item, :expense_group => @eg)
    end

    it "marks the registrant as expense_item_is_free for this expense_item" do
      @reg.expense_item_is_free(@ei).should == true
    end

    describe "when it has a non-free item of the same expense_group (not free though)" do
      before(:each) do
        FactoryGirl.create(:registrant_expense_item, :registrant => @reg, :expense_item => @ei)
        @reg.reload
      end

      it "shows that a free item is available" do
        @reg.expense_item_is_free(@ei).should == true
      end
    end

    describe "when it has a free expense_item" do
      before(:each) do
        FactoryGirl.create(:registrant_expense_item, :registrant => @reg, :expense_item => @ei, :free => true)
        @reg.reload
      end

      it "doesn't allow registrant to have 2 free of this expense_item" do
        @rei = FactoryGirl.build(:registrant_expense_item, :registrant => @reg, :expense_item => @ei, :free => true)
        @rei.valid?.should == false
      end

      it "allows different free expense_items in the same group" do
        @ei2 = FactoryGirl.create(:expense_item, :expense_group => @eg)
        @rei = FactoryGirl.build(:registrant_expense_item, :registrant => @reg, :expense_item => @ei2, :free => true)
        @rei.valid?.should == true
      end
    end
  end

  describe "with an expense_group marked as 'required' created AFTER the non-competitor registrant" do
    before(:each) do
      @nc_reg = FactoryGirl.create(:noncompetitor)
      @eg = FactoryGirl.create(:expense_group, :noncompetitor_required => true)
      @ei = FactoryGirl.create(:expense_item, :expense_group => @eg)
    end

    it "should include this expense_item in the list of owing_registrant_expense_items" do
      @reg.reload
      @reg.owing_registrant_expense_items.count.should == 0
      @nc_reg.reload
      @nc_reg.owing_registrant_expense_items.count.should == 1
      @nc_reg.owing_registrant_expense_items.last.system_managed.should == true
    end
  end

  describe "with an expense_group marked as 'required' created AFTER the registrant" do
    before(:each) do
      @eg = FactoryGirl.create(:expense_group, :competitor_required => true)
      @ei = FactoryGirl.create(:expense_item, :expense_group => @eg)
    end

    it "should include this expense_item in the list of owing_registrant_expense_items" do
      @reg.reload
      @reg.owing_registrant_expense_items.last.expense_item.should == @ei
      @reg.owing_registrant_expense_items.last.system_managed.should == true
    end
  end

  describe "with an expense_group marked as 'required' created BEFORE the registrant" do
    before(:each) do
      @eg = FactoryGirl.create(:expense_group, :competitor_required => true)
      @ei = FactoryGirl.create(:expense_item, :expense_group => @eg)
      @reg2 = FactoryGirl.create(:competitor)
    end

    it "should include this expense_item in the list of owing_registrant_expense_items" do
      @reg2.owing_registrant_expense_items.last.expense_item.should == @ei
      @reg2.owing_registrant_expense_items.last.system_managed.should == true
    end

    describe "when it has paid for the expense_item" do
      before(:each) do
        @payment = FactoryGirl.create(:payment)
        @payment_detail = FactoryGirl.create(:payment_detail, :payment => @payment, :registrant => @reg2, :amount => @ei.cost, :expense_item => @ei)
        @payment.reload
        @payment.completed = true
        @payment.save!
        @reg2.reload
      end

      it "no longer has the item as owing" do
        @reg2.owing_registrant_expense_items.count.should == 0
      end
    end
  end
end
