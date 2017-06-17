class SongPolicy < ApplicationPolicy
  %i[update destroy add_file my_songs create_guest_song file_complete].each do |sym|
    define_method("#{sym}?") do
      # allow DJ to upload new music for other registrants
      music_management?
    end
  end

  def create?
    !config.music_submission_ended? || super_admin?
  end

  def index?
    !config.music_submission_ended? || super_admin?
  end

  private

  def music_management?
    (user_song? && (!config.music_submission_ended? || music_dj?)) || super_admin?
  end

  def user_song?
    record.user == user
  end
end
