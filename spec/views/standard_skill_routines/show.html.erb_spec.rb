require 'spec_helper'

describe "standard_skill_routines/show" do
  before(:each) do
    assign(:entries, [FactoryGirl.create(:standard_skill_routine_entry, standard_skill_entry: FactoryGirl.create(:standard_skill_entry, number: 1, letter: "a", description: "One")),
                      FactoryGirl.create(:standard_skill_routine_entry, standard_skill_entry: FactoryGirl.create(:standard_skill_entry, number: 1, letter: "b", description: "Two")),
                      FactoryGirl.create(:standard_skill_routine_entry, standard_skill_entry: FactoryGirl.create(:standard_skill_entry, number: 1, letter: "c", description: "Three")),
                      FactoryGirl.create(:standard_skill_routine_entry, standard_skill_entry: FactoryGirl.create(:standard_skill_entry, number: 2, letter: "a", description: "Four")),
                      FactoryGirl.create(:standard_skill_routine_entry, standard_skill_entry: FactoryGirl.create(:standard_skill_entry, number: 2, letter: "b", description: "Five"))])
    ssre = FactoryGirl.build(:standard_skill_routine_entry, standard_skill_entry: FactoryGirl.create(:standard_skill_entry, number: 2, letter: "c"))
    assign(:entry, ssre)
    @routine = assign(:standard_skill_routine, ssre.standard_skill_routine)
    assign(:total, 10.1)

    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    @ability.can :manage, StandardSkillRoutine
    @ability.can :manage, StandardSkillRoutineEntry
  end

  it "renders a list of skills" do
    render
    expect(rendered).to match(/One/)
    expect(rendered).to match(/Five/)
  end

  it "renders new entry form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", action: standard_skill_routine_standard_skill_routine_entries_path(@routine), method: "post" do
      assert_select "select#standard_skill_routine_entry_standard_skill_entry_id", name: "standard_skill_routine_entry[standard_skill_entry_id]"
      assert_select "input#standard_skill_routine_entry_position", name: "standard_skill_routine_entry[position]"
    end
  end
end
