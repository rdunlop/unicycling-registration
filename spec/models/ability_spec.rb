require "cancan/matchers"
require "spec_helper"

describe "Ability" do
  describe "as a normal user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
    end
    subject { @ability = Ability.new(@user) }

    it { should be_able_to(:read, @user) }
    it { should_not be_able_to(:read, User.new) }

    describe "with Additional Registrant Accesses" do
      before(:each) do
        @ara = FactoryGirl.create(:additional_registrant_access, :user => @user, :accepted_readonly => true)
        @ara_to_me = FactoryGirl.create(:additional_registrant_access, :registrant => FactoryGirl.create(:registrant, :user => @user))
        @ara_to_other = FactoryGirl.create(:additional_registrant_access)
      end
      it { should be_able_to(:read, @ara) }
      it { should be_able_to(:create, @ara) }
      it { should be_able_to(:new, @ara) }
      it { should be_able_to(:invitations, AdditionalRegistrantAccess) }
      it { should be_able_to(:read, @ara.registrant) }
      it { should_not be_able_to(:read_contact_info, @ara.registrant) }

      it { should be_able_to(:decline, @ara_to_me) }
      it { should be_able_to(:accept_readonly, @ara_to_me) }

      it { should_not be_able_to(:read, FactoryGirl.create(:additional_registrant_access)) }
      it { should_not be_able_to(:decline, @ara_to_other) }
      it { should_not be_able_to(:accept_readonly, @ara_to_other) }
    end

    describe "with a registration" do
      let (:registration) { FactoryGirl.create(:registrant, :user => @user) }

      it { should be_able_to(:read, registration) }
      it { should be_able_to(:read_contact_info, registration) }
      it { should be_able_to(:all, registration) }
      it { should be_able_to(:waiver, registration) }
    end

    describe "With a payment" do
      let (:payment) { FactoryGirl.create(:payment, :user => @user) }

      it { should be_able_to(:read, payment) }
    end
  end
end
