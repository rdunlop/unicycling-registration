require "spec_helper"

describe ExportPolicy do
  subject { described_class }

  let(:user) { FactoryBot.create(:user) }
  let(:export) { FactoryBot.create(:export, exported_by: user) }

  permissions :show? do
    it "denies access to normal user" do
      expect(subject).not_to permit(FactoryBot.create(:user), export)
    end

    it "allows a super_admin" do
      expect(subject).to permit(FactoryBot.create(:super_admin_user), export)
    end

    it "allows the creator" do
      expect(subject).to permit(user, export)
    end
  end
end
