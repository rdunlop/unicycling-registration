require 'spec_helper'

describe "songs/edit" do
  before(:each) do
    @registrant = FactoryGirl.build_stubbed(:registrant)
    @song = FactoryGirl.build_stubbed(:song,
      :description => "MyString",
      :song_file_name => "MyString",
      :registrant => @registrant
    )
  end

  it "renders the edit song form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", song_path(@song, :locale => 'en'), "post" do
      assert_select "input#song_description[name=?]", "song[description]"
      assert_select "select#song_event_id[name=?]", "song[event_id]"
    end
  end
end
