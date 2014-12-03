require 'spec_helper'

describe "standard_scores/new" do

  it "renders successfully all skills" do
    ec = FactoryGirl.create(:competition)
    @c = FactoryGirl.create(:event_competitor, :competition => ec)
    assign(:competitor, @c)
    @routine = FactoryGirl.create(:standard_skill_routine, :registrant => @c.registrants.first)
    @score1 = FactoryGirl.create(:standard_skill_routine_entry, :standard_skill_routine => @routine)
    @score2 = FactoryGirl.create(:standard_skill_routine_entry, :standard_skill_routine => @routine)
    @score3 = FactoryGirl.create(:standard_skill_routine_entry, :standard_skill_routine => @routine)
    assign(:skills, [@score1, @score2, @score3])
    judge = FactoryGirl.create(:judge, :competition => ec)
    sds = judge.standard_difficulty_scores.create()
    sds.standard_skill_routine_entry = @score1
    sds.competitor = @c
    sds.devaluation = 0
    sds.save!

    ses = judge.standard_execution_scores.create()
    ses.standard_skill_routine_entry = @score1
    ses.competitor = @c
    ses.wave = 0
    ses.line = 0
    ses.cross = 0
    ses.circle = 0
    ses.save!

    assign(:judge, judge)

    render

    rendered.should match(@score1.standard_skill_entry.description)
    # assert_select "input#competitor_external_id", :name => "registrant[external_id]"
  end
end
