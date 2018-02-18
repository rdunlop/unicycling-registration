require "spec_helper"

describe ConventionSeriesPolicy do
  let(:series) { FactoryBot.create(:convention_series) }

  subject { described_class }

  permissions :index? do
    it "allows super_admin" do
      expect(subject).to permit(FactoryBot.create(:super_admin_user), series)
    end
  end

  permissions :create? do
    it "allows super_admin" do
      expect(subject).to permit(FactoryBot.create(:super_admin_user), series)
    end
  end
end
