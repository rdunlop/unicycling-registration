require "spec_helper"

describe RegistrantExpenseItemPolicy do
  let(:competition) { FactoryGirl.create(:competition) }

  subject { described_class }

  permissions :create? do
    describe "creating a required expense_item" do
      let(:user) { FactoryGirl.create(:user) }
      let(:registrant) { FactoryGirl.create(:registrant, user: user) }
      before do
        eg = FactoryGirl.create(:expense_group, competitor_required: true)
        @ei = FactoryGirl.create(:expense_item, expense_group: eg)
      end
      it { is_expected.not_to permit(user, registrant.registrant_expense_items.first) }
    end

    describe "with an existing registrant expense item" do
      let(:rei) { FactoryGirl.create(:registrant_expense_item) }

      it "can access own-user registrant expense item" do
        expect(subject).to permit(rei.registrant.user, rei)
      end

      it "cannot access another user's registrant expense item" do
        expect(subject).not_to permit(FactoryGirl.create(:user), rei)
      end

      describe "as a super admin" do
        let(:user) { FactoryGirl.create(:super_admin_user) }
        it { is_expected.to permit(user, rei) }
      end
    end
  end
end
