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
#  comments_by    :string(255)
#  heat           :integer
#  lane           :integer
#
# Indexes
#
#  index_import_results_on_user_id  (user_id)
#  index_imported_results_user_id   (user_id)
#

class ImportResult < ActiveRecord::Base
  include TimePrintable

  validates :competition_id, :presence => true
  validates :user_id, :bib_number, :presence => true
  validate :results_for_competition

  before_validation :clear_status_of_string
  validates :status, :inclusion => { :in => TimeResult.status_values, :allow_nil => true }

  belongs_to :user
  belongs_to :competition

  default_scope { order(:bib_number) }

  scope :entered_order, -> { reorder(:id) }

  def clear_status_of_string
    self.status = nil if status == ""
  end

  def competitor_name
    matching_registrant
  end

  def competitor_exists?
    competition.find_competitor_with_bib_number(bib_number)
  end

  def disqualified
    status == "DQ"
  end

  # import the result in the results table, raise an exception on failure
  def import!
    competitor = competition.find_competitor_with_bib_number(bib_number)
    registrant = matching_registrant
    if competitor.nil?
      competition.create_competitor_from_registrants([registrant], nil)
      competitor = competition.find_competitor_with_bib_number(bib_number)
    end

    tr = competition.build_result_from_imported(self)
    tr.competitor = competitor
    tr.save!
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

  def matching_registrant
    Registrant.find_by(bib_number: bib_number) if bib_number
  end
end
