require 'spec_helper'

describe "combined_competitions/show" do
  before(:each) do
    @combined_competition = FactoryGirl.build_stubbed(:combined_competition, :name => "Name")
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
