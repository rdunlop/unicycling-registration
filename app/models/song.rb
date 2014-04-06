class Song < ActiveRecord::Base
    mount_uploader :song_file_name, MusicUploader

    belongs_to :registrant
    belongs_to :event

    validates :registrant_id, :event_id, :description, presence: true

    def human_name
      return nil unless song_file_name.present?
      File.basename(song_file_name.path)
    end
end
