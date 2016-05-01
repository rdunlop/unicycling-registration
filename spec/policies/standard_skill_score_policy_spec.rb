require "spec_helper"

describe StandardSkillScorePolicy do
  let(:competitor) { FactoryGirl.create(:event_competitor) }
  let(:skill_score) { FactoryGirl.create(:standard_skill_score, competitor: competitor) }

  subject { described_class }

  permissions :new?, :edit?, :create?, :update?, :destroy? do
    let(:user) { FactoryGirl.create(:user) }

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
