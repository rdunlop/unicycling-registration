require "spec_helper"

describe SampleDataPolicy do
  subject { described_class }

  let(:test_mode) { false }
  let(:config) { FactoryBot.create(:event_configuration, test_mode: test_mode) }
  let(:reg_closed?) { false }
  let(:authorized_laptop?) { false }
  let(:user_context) { UserContext.new(user, config, reg_closed?, reg_closed?, reg_closed?, authorized_laptop?) }

  context "a normal user" do
    let(:user) { FactoryBot.create(:user) }

    permissions :create? do
      it { expect(subject).not_to permit(user_context) }
    end
  end

  context "a super user" do
    let(:user) { FactoryBot.create(:super_admin_user) }

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
