require "spec_helper"

describe StandardSkillScorePolicy do
  subject { described_class }

  let(:competitor) { FactoryBot.create(:event_competitor) }
  let(:skill_score) { FactoryBot.create(:standard_skill_score, competitor: competitor) }

  permissions :new?, :edit?, :create?, :update?, :destroy? do
    let(:user) { FactoryBot.create(:user) }

    context "as a director" do
      before do
        user.add_role :director, competitor.event
      end

      it "can change the score" do
        expect(subject).to permit(user, skill_score)
      end
    end

    context "as a normal user" do
      it "cannot change the score" do
        expect(subject).not_to permit(user, skill_score)
      end
    end
  end
end
