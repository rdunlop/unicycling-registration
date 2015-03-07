require 'spec_helper'

describe "convention_setup/categories/edit" do
  before(:each) do
    @category = assign(:category, FactoryGirl.build_stubbed(:category))
  end

  it "renders the edit category form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => convention_setup_categories_path(@category), :method => "post" do
      assert_select "input#category_position", :name => "category[position]"
      assert_select "input#category_info_url", :name => "category[info_url]"
    end
  end
end
