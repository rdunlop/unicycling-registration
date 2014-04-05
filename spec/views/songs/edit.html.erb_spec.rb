require 'spec_helper'

describe "songs/edit" do
  before(:each) do
    @song = assign(:song, stub_model(Song,
      :description => "MyString",
      :song_file_name => "MyString"
    ))
  end

  it "renders the edit song form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", song_path(@song, :locale => 'en'), "post" do
      assert_select "input#song_description[name=?]", "song[description]"
      assert_select "input#song_song_file_name[name=?]", "song[song_file_name]"
    end
  end
end
