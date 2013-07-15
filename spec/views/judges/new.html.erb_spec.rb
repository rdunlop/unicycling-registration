require 'spec_helper'

describe "judges/new" do
  before(:each) do
    assign(:judge, FactoryGirl.build(:judge))
    @ev = FactoryGirl.create(:event)
    @ec = @ev.event_categories.first
    assign(:event_category, @ec)
    assign(:judge_types, [])
    assign(:all_judges, [])
    assign(:judge, Judge.new)
  end
  it "should show the 'new judge type'" do
    render

    assert_select "form", :action => event_category_judges_path(@ec), :method => "post" do
      assert_select "select#judge_judge_type_id", :name => "judge[judge_type_id]"
      assert_select "select#judge_user_id", :name => "judge[user_id]"
    end
  end

  it "should show the 'copy judges' form" do
    render
    assert_select "form", :url => copy_judges_event_category_judges_path(@ec), :method => "post" do
        assert_select "select#copy_judges_event_id", :name => "copy_judges[event_id]"
    end
  end

end
