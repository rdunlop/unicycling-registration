# == Schema Information
#
# Table name: award_labels
#
#  id            :integer          not null, primary key
#  bib_number    :integer
#  line_2        :string(255)
#  line_3        :string(255)
#  line_5        :string(255)
#  place         :integer
#  user_id       :integer
#  registrant_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#  line_1        :string(255)
#  line_4        :string(255)
#
# Indexes
#
#  index_award_labels_on_user_id  (user_id)
#

class AwardLabel < ActiveRecord::Base
  validates :registrant_id, presence: true
  validates :user_id, presence: true
  validates :place, presence: true, numericality: {greater_than: 0}

  belongs_to :user
  belongs_to :registrant

  def populate_from_competitor(competitor, registrant, place, expert = false)
    result = find_result(competitor, expert)

    self.line_1 = result.competitor_name(registrant)
    self.line_2 = result.competition_name
    self.line_3 = result.team_name
    self.line_4 = result.category_name
    self.line_5 = result.details
    self.place = result.place # line 6

    # misc housekeeping
    self.registrant = registrant
    self.bib_number = registrant.bib_number
  end

  def line_6
    case place
    when 1
      "1st Place"
    when 2
      "2nd Place"
    when 3
      "3rd Place"
    when 4
      "4th Place"
    when 5
      "5th Place"
    when 6
      "6th Place"
    end
  end

  private

  def find_result(competitor, expert)
    if expert || !competitor.competition.has_age_group_entry_results?
      competitor.overall_result
    else
      competitor.age_group_result
    end
  end

end
