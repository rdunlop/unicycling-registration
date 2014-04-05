require 'spec_helper'

describe "songs/show" do
  before(:each) do
    @song = assign(:song, FactoryGirl.build_stubbed(:song,
      :description => "Description",
      :song_file_name => "File Name"
    ))
    # need this to get past the fact that carrierwave
    # overwrites this column
    allow(@song).to receive(:song_file_name).and_return("File Name")
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Description/)
    rendered.should match(/File Name/)
  end
end
