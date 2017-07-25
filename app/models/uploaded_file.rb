# == Schema Information
#
# Table name: uploaded_files
#
#  id             :integer          not null, primary key
#  competition_id :integer          not null
#  user_id        :integer          not null
#  filename       :string           not null
#  file           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_uploaded_files_on_competition_id  (competition_id)
#  index_uploaded_files_on_user_id         (user_id)
#

class UploadedFile < ApplicationRecord
  mount_uploader :file, ImportedFileUploader

  belongs_to :user
  belongs_to :competition
  validates :filename, presence: true

  # Read the params for either
  # 'file' -> Store the file and pass back a reference to the new stored file
  # or
  # 'uploaded_file_id' -> read the stored file
  def self.process_params(params, competition:, user:)
    if params[:file]
      uploaded_file = competition.uploaded_files.new(user: user)
      uploaded_file.file = params[:file]
      uploaded_file.filename = params[:file].original_filename
      uploaded_file.save!
      uploaded_file
    else
      competition.uploaded_files.find(params[:uploaded_file_id])
    end
  end
end
