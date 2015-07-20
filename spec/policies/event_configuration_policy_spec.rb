require "spec_helper"

describe EventConfigurationPolicy do
  let(:event_configuration) { FactoryGirl.build_stubbed(:event_configuration) }

  subject { described_class }

  permissions :setup_competition? do
    it "denies access to normal user" do
      expect(subject).not_to permit(FactoryGirl.create(:user), event_configuration)
    end

    it "grants access to super_admin" do
      expect(subject).to permit(FactoryGirl.create(:super_admin_user), event_configuration)
    end

    it "grants access to competition_admin" do
      expect(subject).to permit(FactoryGirl.create(:competition_admin_user), event_configuration)
    end
  end

  permissions :setup_convention? do
    it "denies access to normal user" do
      expect(subject).not_to permit(FactoryGirl.create(:user), event_configuration)
    end

    it "grants access to super_admin" do
      expect(subject).to permit(FactoryGirl.create(:super_admin_user), event_configuration)
    end

    it "grants access to convention_admin" do
      expect(subject).to permit(FactoryGirl.create(:convention_admin_user), event_configuration)
    end
  end
end
