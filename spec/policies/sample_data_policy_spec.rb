require "spec_helper"

describe SampleDataPolicy do
  let(:test_mode) { false }
  let(:config) { FactoryGirl.create(:event_configuration, test_mode: test_mode) }
  let(:reg_closed?) { false }
  let(:authorized_laptop?) { false }
  let(:user_context) { UserContext.new(user, config, reg_closed?, reg_closed?, authorized_laptop?) }

  subject { described_class }

  context "a normal user" do
    let(:user) { FactoryGirl.create(:user) }

    permissions :create? do
      it { expect(subject).not_to permit(user_context) }
    end
  end

  context "a super user" do
    let(:user) { FactoryGirl.create(:super_admin_user) }

    context "when test mode is disabled" do
      permissions :create? do
        it { expect(subject).not_to permit(user_context) }
      end
    end
    context "when test mode is enabled" do
      let(:test_mode) { true }

      permissions :create? do
        it { expect(subject).to permit(user_context) }
      end
    end
  end
end
