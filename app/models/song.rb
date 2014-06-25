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
#
# Indexes
#
#  index_songs_registrant_id  (registrant_id)
#

class Song < ActiveRecord::Base
    mount_uploader :song_file_name, MusicUploader

    belongs_to :registrant, touch: true
    belongs_to :event

    validates :registrant_id, :event_id, :description, presence: true

    validates :event_id, uniqueness: { scope: [:registrant_id], message: "cannot have multiple songs associated. Remove and re-add." }

    def human_name
      return nil unless song_file_name.present?
      File.basename(song_file_name.path)
    end
end
