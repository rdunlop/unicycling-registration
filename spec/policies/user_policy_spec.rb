require "spec_helper"

describe UserPolicy do
  let(:user) { FactoryGirl.create(:user) }

  subject { described_class }

  permissions :registrants? do
    it "allows access to my registrants page" do
      expect(subject).to permit(user, user)
    end

    it "disallows access to another registrant" do
      expect(subject).to_not permit(FactoryGirl.create(:user), user)
    end

    it "grants access to super_admin" do
      expect(subject).to permit(FactoryGirl.create(:super_admin_user), user)
    end
  end

  permissions :logged_in? do
    # throws an exception
    # it "doesn't allow access when not logged in" do
    #   expect(subject).not_to permit(nil, user)
    # end

    it "allows access when logged in" do
      expect(subject).to permit(user, user)
    end
  end
end
