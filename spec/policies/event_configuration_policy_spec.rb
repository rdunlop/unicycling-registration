require "spec_helper"

describe EventConfigurationPolicy do
  subject { described_class }

  let(:event_configuration) { FactoryBot.build_stubbed(:event_configuration) }

  permissions :setup_competition? do
    it "denies access to normal user" do
      expect(subject).not_to permit(FactoryBot.create(:user), event_configuration)
    end

    it "grants access to super_admin" do
      expect(subject).to permit(FactoryBot.create(:super_admin_user), event_configuration)
    end

    it "grants access to competition_admin" do
      expect(subject).to permit(FactoryBot.create(:competition_admin_user), event_configuration)
    end
  end

  permissions :setup_convention? do
    it "denies access to normal user" do
      expect(subject).not_to permit(FactoryBot.create(:user), event_configuration)
    end

    it "grants access to super_admin" do
      expect(subject).to permit(FactoryBot.create(:super_admin_user), event_configuration)
    end

    it "grants access to convention_admin" do
      expect(subject).to permit(FactoryBot.create(:convention_admin_user), event_configuration)
    end
  end
end
