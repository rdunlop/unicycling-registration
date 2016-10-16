# == Schema Information
#
# Table name: scores
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  val_1         :decimal(5, 3)
#  val_2         :decimal(5, 3)
#  val_3         :decimal(5, 3)
#  val_4         :decimal(5, 3)
#  notes         :text
#  judge_id      :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_scores_competitor_id                  (competitor_id)
#  index_scores_judge_id                       (judge_id)
#  index_scores_on_competitor_id_and_judge_id  (competitor_id,judge_id) UNIQUE
#

require 'spec_helper'

describe ScoresController do
  before (:each) do
    @user = FactoryGirl.create(:data_entry_volunteer_user)
    @other_user = FactoryGirl.create(:data_entry_volunteer_user)

    @judge = FactoryGirl.create(:judge, user_id: @user.id)
    @jt = FactoryGirl.create(:judge_type)
    @judge_with_pres = FactoryGirl.create(:judge, judge_type: @jt, user_id: @other_user.id)
    @other_judge = FactoryGirl.create(:judge, user_id: @other_user.id)

    @comp = FactoryGirl.create(:event_competitor, competition: @judge.competition)
    @comp2 = FactoryGirl.create(:event_competitor, competition: @judge.competition)
    @judge.competition.competitors << @comp2
    @judge.competition.competitors << @comp
    @judge.save!

    @signed_in_scores = [
      FactoryGirl.create(:score, judge: @judge, competitor: @comp, val_1: 3.22),
      FactoryGirl.create(:score, judge: @judge, competitor: @comp2, val_1: 2.33)]

    # director
    @user.add_role :director, @judge.competition

    sign_in @user
  end

  # This should return the minimal set of attributes required to create a valid
  # Score. As you add validations to Score, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { val_1: 1.1,
      val_2: 2.2,
      val_3: 3.3,
      val_4: 4.4,
      notes: "hi"
    }
  end

  describe "GET index" do
    it "renders the titles and ranges" do
      get :index, params: { judge_id: @judge.id }

      assert_match(/#{@judge.judge_type.val_1_description}/, response.body)
      assert_match(/\(0-#{@judge.judge_type.val_1_max}\)/, response.body)
    end

    it "renders a list of scores" do
      # vary the data
      score = @signed_in_scores[0]
      score.update(val_1: 5.1, val_2: 2.109, val_3: 3.19, val_4: 4.1)

      get :index, params: { judge_id: @judge.id }

      # assert_select "tr>td", text: @comp.bib_number.to_s, count: 1
      assert_select "tr>td", text: @comp.name.to_s, count: 1
      assert_select "tr>td", text: "5.1".to_s, count: 1
      assert_select "tr>td", text: "2.109".to_s, count: 1
      assert_select "tr>td", text: "3.19".to_s, count: 1
      assert_select "tr>td", text: "4.1".to_s, count: 1
      assert_select "tr>td", text: "14.499".to_s, count: 1

      # assert_select "tr>td", text: @comp2.bib_number.to_s, count: 1
      assert_select "tr>td", text: @comp2.name.to_s, count: 1
      assert_select "tr>td", text: "2.33".to_s, count: 1
      assert_select "tr>td", text: "1.2".to_s, count: 1
      assert_select "tr>td", text: "1.3".to_s, count: 1
      assert_select "tr>td", text: "1.4".to_s, count: 1
      assert_select "tr>td", text: "6.23".to_s, count: 1
    end

    it "shows the update button" do
      get :index, params: { judge_id: @judge.id }

      assert_select "a", text: "Set Score".to_s, count: 2
    end

    it "doesn't show the update button if event is locked" do
      @judge.competition.update(locked_at: DateTime.current)

      get :index, params: { judge_id: @judge.id }

      assert_select "a", text: "Set Score".to_s, count: 0
    end

    it "shows a 'this event is locked' message when the event is locked" do
      @judge.competition.update(locked_at: DateTime.current)

      get :index, params: { judge_id: @judge.id }

      assert_match(/Scores for this event are now locked \(closed\)/, response.body)
    end
  end

  describe "GET new" do
    it "shows the requested score" do
      get :new, params: { judge_id: @judge.id, competitor_id: @comp.id }

      assert_select "h3", "Judge: #{@judge}"
      assert_select "input[value=?]", @signed_in_scores[0].val_1.to_s, count: 1
      assert_select "td", @signed_in_scores[1].val_1.to_s, count: 1
    end
  end

  describe "POST create" do
    before(:each) do
      sign_out @user
      sign_in @other_user
    end
    describe "with valid params" do
      it "creates a new Score" do
        expect do
          post :create, params: { score: valid_attributes, judge_id: @other_judge.id, competitor_id: @comp.id }
        end.to change(Score, :count).by(1)
      end
    end
  end

  describe "when the competition is locked" do
    before(:each) do
      @comp.competition.locked_at = DateTime.now
      @comp.competition.save!
    end
    it "should not be allowed to create scores" do
      expect do
        post :create, params: { score: valid_attributes, judge_id: @other_judge.id, competitor_id: @comp.id }
      end.to change(Score, :count).by(0)
    end
  end

  describe "POST create On an existing score" do
    describe "with valid params" do
      it "redirects to the score" do
        post :create, params: { score: valid_attributes, judge_id: @judge, competitor_id: @comp.id }
        expect(response).to redirect_to(judge_scores_url(@judge))
      end
    end

    describe "with invalid params" do
      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Score).to receive(:save).and_return(false)
        post :create, params: { score: {val_1: 1}, judge_id: @judge.id, competitor_id: @comp.id }
        assert_select "h3", "Judge: #{@judge}"
      end
    end

    describe "authentication of edit/update pages" do
      # http://ruby.railstutorial.org/chapters/updating-showing-and-deleting-users#sec:protecting_pages

      before (:each) do
        # create score with existing current_user
        @user_score = @signed_in_scores[0]

        # Change logged-in user
        sign_out @user
        @auth_user = FactoryGirl.create(:user)
        sign_in @auth_user
      end
      it "should deny access to edit" do
        get :new, params: { judge_id: @judge, competitor_id: @comp.id }
        expect(response).to redirect_to(root_path)
      end
      it "should deny access to update" do
        post :create, params: { judge_id: @judge, competitor_id: @comp.id }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
