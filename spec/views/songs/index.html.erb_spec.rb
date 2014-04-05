require 'spec_helper'

describe "songs/index" do
  before(:each) do
    @registrant = FactoryGirl.build_stubbed(:registrant)
    @song1 = FactoryGirl.build_stubbed(:song,
        :description => "Description",
        :song_file_name => "File Name",
        :registrant => @registrant
    )
    @song2 = FactoryGirl.build_stubbed(:song,
        :description => "Description",
        :song_file_name => "File Name",
        :registrant => @registrant
    )
    assign(:songs, [@song1, @song2])
    # carrierwasve overwrites these columns
    allow(@song1).to receive(:song_file_name_url).and_return("http://localhost/file1.mp3")
    allow(@song2).to receive(:song_file_name_url).and_return("http://localhost/file2.mp3")

    allow(@song1).to receive(:human_name).and_return("File Name")
    allow(@song2).to receive(:human_name).and_return("File Name")
    assign(:song, stub_model(Song,
      :description => "MyString",
      :file_name => "MyString"
    ).as_new_record)
  end

  it "renders a list of songs" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => "File Name".to_s, :count => 2
  end

  it "renders new song form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", registrant_songs_path(@registrant, :locale => 'en'), "post" do
      assert_select "input#song_description[name=?]", "song[description]"
      assert_select "input#song_song_file_name[name=?]", "song[song_file_name]"
    end
  end
end
