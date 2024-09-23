require "spec_helper"

describe StandardSkillRoutinePolicy do
  subject { described_class }

  let(:my_user) { FactoryBot.create(:user) }
  let(:my_registrant) { FactoryBot.create(:registrant, user: my_user) }
  let(:other_registrant) { FactoryBot.create(:registrant) }
  let(:my_routine) { FactoryBot.create(:standard_skill_routine, registrant: my_registrant) }
  let(:other_routine) { FactoryBot.create(:standard_skill_routine, registrant: other_registant) }
  let(:event_planner) { FactoryBot.create(:event_planner) }
  let(:std_director) { FactoryBot.create(:user) }
  let(:other_director) { FactoryBot.create(:user) }
  let(:standard_skill_event) { FactoryBot.create(:event, :standard_skill) }

  before do
    std_director.add_role :director, standard_skill_event
    other_director.add_role :director, FactoryBot.create(:event)
  end

  permissions :show? do
    it { expect(subject).to permit(my_user, my_routine) }
    it { expect(subject).not_to permit(other_registrant.user, my_routine) }
  end

  permissions :writing_judge?, :difficulty_judge?, :execution_judge? do
    it { expect(subject).to permit(event_planner, my_routine) }
    it { expect(subject).to permit(std_director, my_routine) }
    it { expect(subject).not_to permit(other_director, my_routine) }
  end

  describe "with a user context" do
    let(:reg_closed?) { false }
    let(:authorized_laptop?) { false }
    let(:user) { my_user }
    let(:standard_skill_closed?) { false }
    let(:config) { double(standard_skill_closed?: standard_skill_closed?) }
    let(:user_context) { UserContext.new(user, config, reg_closed?, reg_closed?, reg_closed?, authorized_laptop?) }

    permissions :create? do
      it { expect(subject).to permit(user_context, my_routine) }
    end
  end
end
