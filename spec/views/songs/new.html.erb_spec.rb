require 'spec_helper'

describe "songs/new" do
  before(:each) do
    assign(:song, stub_model(Song,
      :description => "MyString",
      :file_name => "MyString"
    ).as_new_record)
  end

  it "renders new song form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", songs_path(:locale => 'en'), "post" do
      assert_select "input#song_description[name=?]", "song[description]"
      assert_select "input#song_song_file_name[name=?]", "song[song_file_name]"
    end
  end
end
