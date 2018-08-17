require "spec_helper"

describe CompetitionPolicy do
  subject { described_class }

  let(:competition) { FactoryBot.create(:competition) }

  permissions :manage_lane_assignments? do
    it "denies access to normal user" do
      expect(subject).not_to permit(FactoryBot.create(:user), competition)
    end

    it "grants access to super_admin" do
      expect(subject).to permit(FactoryBot.create(:super_admin_user), competition)
    end

    it "grants access to race official for this competition" do
      user = FactoryBot.create(:user)
      user.add_role :race_official, competition
      expect(subject).to permit(user, competition)
    end
  end

  permissions :show? do
    describe "as data_entry volunteer" do
      let(:user) { FactoryBot.create(:data_entry_volunteer_user) }

      it "is not accessible" do
        expect(subject).not_to permit(user, competition)
      end
    end

    describe "as a director" do
      let(:user) { FactoryBot.create(:user) }

      before do
        user.add_role(:director, competition.event)
      end

      it "is accessible" do
        expect(subject).to permit(user, competition)
      end
    end

    describe "as normal user" do
      it { expect(subject).not_to permit(FactoryBot.create(:user), competition) }
    end
  end

  permissions :sort? do
    before do
      @director = FactoryBot.create(:user)
      @director.add_role :director, competition.event
    end

    let(:normal_user) { FactoryBot.create(:user) }

    it { expect(subject).not_to permit(normal_user, competition) }
    it { expect(subject).to permit(@director, competition) }

    describe "with an locked competition" do
      let(:competition) { FactoryBot.create(:competition, :locked) }

      it { expect(subject).not_to permit(@director, competition) }
    end
  end
end
