require "spec_helper"

describe StandardSkillRoutinePolicy do
  let(:my_user) { FactoryGirl.create(:user)}
  let(:my_registrant) { FactoryGirl.create(:registrant, user: my_user) }
  let(:other_registrant) { FactoryGirl.create(:registrant) }
  let(:my_routine) { FactoryGirl.create(:standard_skill_routine, registrant: my_registrant)}
  let(:other_routine) { FactoryGirl.create(:standard_skill_routine, registrant: other_registant)}
  let(:event_planner) { FactoryGirl.create(:event_planner) }
  let(:std_director) { FactoryGirl.create(:user) }
  let(:other_director) { FactoryGirl.create(:user) }
  let(:standard_skill_event) { FactoryGirl.create(:event, :standard_skill)}
  before do
    std_director.add_role :director, standard_skill_event
    other_director.add_role :director, FactoryGirl.create(:event)
  end

  subject { described_class }

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
    let(:user_context) { UserContext.new(user, config, reg_closed?, authorized_laptop?) }

    permissions :create? do
      it { expect(subject).to permit(user_context, my_routine) }
    end
  end
end
