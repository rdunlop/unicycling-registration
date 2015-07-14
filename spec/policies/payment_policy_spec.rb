require "spec_helper"

describe PaymentPolicy do
  let(:my_user) { FactoryGirl.create(:user)}
  let(:my_payment) { FactoryGirl.build(:payment, user: my_user) }

  subject { described_class }

  permissions :create? do
    let(:reg_closed?) { false }
    let(:authorized_laptop?) { false }
    let(:user) { my_user }
    let(:config) { FactoryGirl.create(:event_configuration) }
    let(:user_context) { UserContext.new(user, config, reg_closed?, authorized_laptop?) }

    describe "while registration is open" do

      it "allows creation" do
        expect(subject).to permit(user_context, my_payment)
      end
    end

    describe "when registration is closed" do
      let(:reg_closed?) { true }

      describe "on a normal laptop" do
        it { expect(subject).not_to permit(user_context, my_payment) }
      end

      describe "on an authorized laptop" do
        let(:authorized_laptop?) { true }

        it { expect(subject).to permit(user_context, my_payment) }
      end

      describe "as a super_admin" do
        let(:user) { FactoryGirl.create(:super_admin_user) }

        it { expect(subject).to permit(user_context, my_payment) }
      end
    end
  end

  permissions :fake_complete? do
    let(:test_mode) { false }
    let(:reg_closed?) { false }
    let(:authorized_laptop?) { false }
    let(:user) { my_user }
    let(:config) { FactoryGirl.create(:event_configuration, test_mode: test_mode) }
    let(:user_context) { UserContext.new(user, config, reg_closed?, authorized_laptop?) }

    describe "while registration is open" do

      it "doesn't allow fake_complete" do
        expect(subject).not_to permit(user_context, my_payment)
      end
    end

    describe "when test mode is enabled" do
      let(:test_mode) { true }
      it "allows fake-complete" do
        expect(subject).to permit(user_context, my_payment)
      end
    end
  end
end
