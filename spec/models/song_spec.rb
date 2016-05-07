# == Schema Information
#
# Table name: songs
#
#  id             :integer          not null, primary key
#  registrant_id  :integer
#  description    :string(255)
#  song_file_name :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  event_id       :integer
#  user_id        :integer
#  competitor_id  :integer
#
# Indexes
#
#  index_songs_on_competitor_id                           (competitor_id) UNIQUE
#  index_songs_on_user_id_and_registrant_id_and_event_id  (user_id,registrant_id,event_id) UNIQUE
#  index_songs_registrant_id                              (registrant_id)
#

require 'spec_helper'

describe Song do
  let(:song) { FactoryGirl.build_stubbed(:song) }
  it "must be valid by default" do
    expect(song.valid?).to eq(true)
  end
  it "must have an event" do
    song.event = nil
    expect(song.valid?).to eq(false)
  end

  it "must have a description" do
    song.event = FactoryGirl.build_stubbed(:event)
    song.description = nil
    expect(song.valid?).to eq(false)
  end

  describe "with a song created" do
    let(:registrant) { FactoryGirl.create(:registrant) }
    let!(:song1) { FactoryGirl.create(:song, registrant: registrant)}

    it "cannot create a second song for the same event for the same registrant" do
      song2 = FactoryGirl.build(:song, registrant: registrant, event: song1.event, user: song1.user)
      expect(song2).to be_invalid
    end

    it "can create a second song for the same event, different registrant" do
      song1a = FactoryGirl.build(:song, event: song1.event, user: song1.user)
      expect(song1a).to be_valid
    end
  end

  describe "validations" do
    subject(:song) { FactoryGirl.build(:song) }
    it { is_expected.to validate_presence_of(:registrant_id) }
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:event_id) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_uniqueness_of(:competitor_id).with_message("Cannot assign more than 1 song to the same competitor for this competition") }
    it { is_expected.to validate_uniqueness_of(:event_id).scoped_to([:user_id, :registrant_id]).with_message("cannot have multiple songs associated. Remove and re-add.") }
  end
end
