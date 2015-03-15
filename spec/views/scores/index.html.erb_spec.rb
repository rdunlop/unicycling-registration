require 'spec_helper'

describe "scores/index" do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }

    @ec = FactoryGirl.create(:competition)
    @judge = FactoryGirl.create(:judge, :competition => @ec)
    assign(:judge, @judge)
    assign(:judges, [])
    @comp1 = FactoryGirl.create(:event_competitor, :competition => @ec)
    @comp2 = FactoryGirl.create(:event_competitor, :competition => @ec)

    # differentiate the external_id from the other data.
    r = Competitor.find(@comp1.id).members.first.registrant
    r.bib_number = 101
    r.save

    r = Competitor.find(@comp2.id).members.first.registrant
    r.bib_number = 102
    r.save

    jt = @judge.judge_type
    jt.val_1_max = 23
    jt.save

    score = FactoryGirl.create(:score, :judge => @judge, :competitor => @comp1)
    score.val_1 = 5.1
    score.val_2 = 2.109
    score.val_3 = 3.190
    score.val_4 = 4.1
    score.notes = "My Notes"
    score.save!

    score2 = FactoryGirl.create(:score, :judge => @judge, :competitor => @comp2)

    assign(:competitors, [@comp1, @comp2])
  end
  it "renders the titles and ranges" do
    render
    expect(rendered).to match(/#{@judge.judge_type.val_1_description}/)
    expect(rendered).to match(/\(0-#{@judge.judge_type.val_1_max}\)/)
  end

  it "renders a list of scores" do
    render
    assert_select "tr:nth-child(1)" do |row|
      assert_select "td", :text => @comp1.bib_number.to_s, :count => 1
      assert_select "td", :text => @comp1.name.to_s, :count => 1
      assert_select "td", :text => "5.1".to_s, :count => 1
      assert_select "td", :text => "2.109".to_s, :count => 1
      assert_select "td", :text => "3.19".to_s, :count => 1
      assert_select "td", :text => "4.1".to_s, :count => 1
      assert_select "td", :text => "14.499".to_s, :count => 1
    end
    assert_select "tr:nth-child(2)" do |row|
      assert_select "td", :text => @comp2.bib_number.to_s, :count => 1
      assert_select "td", :text => @comp2.name.to_s, :count => 1
      assert_select "td", :text => "1.1".to_s, :count => 1
      assert_select "td", :text => "1.2".to_s, :count => 1
      assert_select "td", :text => "1.3".to_s, :count => 1
      assert_select "td", :text => "1.4".to_s, :count => 1
      assert_select "td", :text => "5.0".to_s, :count => 1
    end
  end
  it "shows the update button" do
    @ability.can :create_scores, @ec
    render
    assert_select "a", :text => "Set Score".to_s, :count => 2
  end
  it "doesn't show the update button if event is locked" do
    render
    assert_select "tr:nth-child(1)" do |row|
      assert_select "a", :text => "Set Score".to_s, :count => 0
    end
  end

  it "shows a 'this event is locked' message when the event is locked" do
    render
    expect(rendered).to match(/Scores for this event are now locked \(closed\)/)
  end
end
