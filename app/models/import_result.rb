# == Schema Information
#
# Table name: import_results
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  raw_data       :string(255)
#  bib_number     :integer
#  minutes        :integer
#  seconds        :integer
#  thousands      :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  competition_id :integer
#  rank           :integer
#  details        :string(255)
#  is_start_time  :boolean          default(FALSE)
#  attempt_number :integer
#  status         :string(255)
#  comments       :text
#

class ImportResult < ActiveRecord::Base
  validates :competition_id, :presence => true
  validates :user_id, :bib_number, :presence => true
  validate :results_for_competition

  validates :status, :inclusion => { :in => TimeResult.status_values, :allow_nil => true }

  belongs_to :user
  belongs_to :competition

  default_scope { order(:bib_number) }

  def competitor_name
    Registrant.find_by(bib_number: bib_number) if bib_number
  end

  def competitor_exists?
    competition.find_competitor_with_bib_number(bib_number)
  end

  def disqualified
    status == "DQ"
  end

  private

  # determines that the import_result has enough information
  def results_for_competition
    return if disqualified
    unless time_is_present? || rank
      errors.add(:base, "Must select either time or rank")
    end
  end

  def time_is_present?
    minutes && seconds && thousands
  end
end
