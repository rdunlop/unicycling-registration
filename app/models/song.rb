class Song < ActiveRecord::Base
    mount_uploader :song_file_name, MusicUploader

    belongs_to :registrant
    belongs_to :event

    def human_name
      return nil unless song_file_name.present?
      File.basename(song_file_name.path)
    end
end
