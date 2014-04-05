require 'spec_helper'

describe "songs/index" do
  before(:each) do
    @song1 = FactoryGirl.build_stubbed(:song,
        :description => "Description",
        :song_file_name => "File Name"
    )
    @song2 = FactoryGirl.build_stubbed(:song,
        :description => "Description",
        :song_file_name => "File Name"
    )
    assign(:songs, [@song1, @song2])
    # carrierwasve overwrites these columns
    allow(@song1).to receive(:song_file_name).and_return("File Name")
    allow(@song2).to receive(:song_file_name).and_return("File Name")
  end

  it "renders a list of songs" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => "File Name".to_s, :count => 2
  end
end
