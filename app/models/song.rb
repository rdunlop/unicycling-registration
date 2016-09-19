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

class Song < ApplicationRecord
  mount_uploader :song_file_name, MusicUploader
  include CachedModel

  belongs_to :registrant, touch: true
  belongs_to :event
  belongs_to :user
  belongs_to :competitor

  validates :registrant_id, :user_id, :event_id, :description, presence: true
  validates :competitor_id, uniqueness: { message: "Cannot assign more than 1 song to the same competitor for this competition" }, allow_nil: true

  validates :event_id, uniqueness: { scope: [:user_id, :registrant_id], message: "cannot have multiple songs associated. Remove and re-add." }
  validate :song_size_validation

  def human_name
    return nil unless has_file?
    File.basename(song_file_name.path)
  end

  def has_file?
    song_file_name.present?
  end

  def uploaded_by_guest?
    user != registrant.user
  end

  private

  def song_size_validation
    errors[:song_file_name] << "should be less than 40MB" if song_file_name.size > 40.megabytes
  end
end
