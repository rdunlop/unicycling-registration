class SongPolicy < ApplicationPolicy

  [:create, :update, :destroy, :file_complete, :add_file, :my_songs, :create_guest_song].each do |sym|
    define_method("#{sym}?") do
      music_submission_ended?
    end
  end

  def index?
    !music_submission_ended? || super_admin?
  end

  private

  def music_submission_ended?
    (user_song? && !config.music_submission_ended?) || super_admin?
  end

  def user_song?
    record.user == user
  end

end
