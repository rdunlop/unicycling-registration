require 'spec_helper'

describe "categories/show" do
  before(:each) do
    @category = assign(:category, stub_model(Category,
      :name => "Name",
      :position => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/1/)
  end
end
