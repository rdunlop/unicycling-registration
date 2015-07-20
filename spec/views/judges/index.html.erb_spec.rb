require 'spec_helper'

describe "judges/index" do
  before(:each) do
    assign(:judge, FactoryGirl.build(:judge))
    @ec = FactoryGirl.create(:competition)
    assign(:competition, @ec)
    assign(:events, [])
    assign(:all_data_entry_volunteers, [])
    assign(:judge_types, [])
    assign(:judges, [])
    assign(:competitions_with_judges, [])
    assign(:judge, Judge.new(competition: @ec))

    user = FactoryGirl.create(:super_admin_user)
    sign_in user
  end

  it "should show the 'new judge type'" do
    render

    assert_select "form", action: competition_judges_path(@ec), method: "post" do
      assert_select "select#judge_judge_type_id", name: "judge[judge_type_id]"
      assert_select "select#judge_user_id", name: "judge[user_id]"
    end
  end

  it "should show the 'copy judges' form" do
    render
    assert_select "form", url: copy_judges_competition_judges_path(@ec), method: "post" do
      assert_select "select#copy_judges_competition_id", name: "copy_judges[competition_id]"
    end
  end
end
