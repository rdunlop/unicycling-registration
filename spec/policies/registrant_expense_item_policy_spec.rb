require "spec_helper"

describe RegistrantExpenseItemPolicy do
  let(:competition) { FactoryBot.create(:competition) }

  subject { described_class }

  permissions :create? do
    describe "creating a required expense_item" do
      let(:user) { FactoryBot.create(:user) }
      let(:registrant) { FactoryBot.create(:registrant, user: user) }
      before do
        eg = FactoryBot.create(:expense_group, competitor_required: true)
        @ei = FactoryBot.create(:expense_item, expense_group: eg)
      end
      it { is_expected.not_to permit(user, registrant.registrant_expense_items.first) }
    end

    describe "with an existing registrant expense item" do
      let(:rei) { FactoryBot.create(:registrant_expense_item) }

      it "can access own-user registrant expense item" do
        expect(subject).to permit(rei.registrant.user, rei)
      end

      it "cannot access another user's registrant expense item" do
        expect(subject).not_to permit(FactoryBot.create(:user), rei)
      end

      describe "as a super admin" do
        let(:user) { FactoryBot.create(:super_admin_user) }
        it { is_expected.to permit(user, rei) }
      end
    end
  end
end
