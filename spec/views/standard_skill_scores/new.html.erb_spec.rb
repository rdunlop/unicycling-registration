require 'spec_helper'

describe "standard_skill_scores/new" do
  it "renders successfully all skills" do
    ec = FactoryGirl.create(:competition)
    @c = FactoryGirl.create(:event_competitor, competition: ec)
    assign(:competitor, @c)
    @routine = FactoryGirl.create(:standard_skill_routine, registrant: @c.registrants.first)
    @score1 = FactoryGirl.create(:standard_skill_routine_entry, standard_skill_routine: @routine)
    @score2 = FactoryGirl.create(:standard_skill_routine_entry, standard_skill_routine: @routine)
    @score3 = FactoryGirl.create(:standard_skill_routine_entry, standard_skill_routine: @routine)
    judge = FactoryGirl.create(:judge, competition: ec)
    assign(:judge, judge)

    sss = judge.standard_skill_scores.build
    sss.standard_skill_score_entries.build(standard_skill_routine_entry: @score1)
    sss.standard_skill_score_entries.build(standard_skill_routine_entry: @score2)
    sss.standard_skill_score_entries.build(standard_skill_routine_entry: @score3)
    assign(:standard_skill_score, sss)

    render

    expect(rendered).to match(@score1.standard_skill_entry.description)
    # assert_select "input#competitor_external_id", :name => "registrant[external_id]"
  end
end
