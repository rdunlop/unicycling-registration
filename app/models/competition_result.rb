# == Schema Information
#
# Table name: competition_results
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  results_file   :string(255)
#  system_managed :boolean
#  published      :boolean
#  published_date :datetime
#  created_at     :datetime
#  updated_at     :datetime
#

class CompetitionResult < ActiveRecord::Base

  belongs_to :competition, :inverse_of => :competition_results, touch: true

  validates :competition, presence: true
  validates :published_date, :results_file, presence: true
  validates :system_managed, :uniqueness => { :scope => [:competition_id] }, if:  Proc.new{ |f| f.system_managed? }

  before_destroy :remove_uploaded_file

  mount_uploader :results_file, PdfUploader

  def self.active
    where(published: true)
  end

  def remove_uploaded_file
    remove_results_file!
  end

  def published_date_to_s
    published_date.to_formatted_s(:short) if published_date
  end

  def to_s
    if system_managed
      "Results"
    else
      "Additional Results"
    end
  end
end
