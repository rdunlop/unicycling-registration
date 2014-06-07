# == Schema Information
#
# Table name: award_labels
#
#  id               :integer          not null, primary key
#  bib_number       :integer
#  competition_name :string(255)
#  team_name        :string(255)
#  details          :string(255)
#  place            :integer
#  user_id          :integer
#  registrant_id    :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  competitor_name  :string(255)
#  category         :string(255)
#
# Indexes
#
#  index_award_labels_on_user_id  (user_id)
#

class AwardLabel < ActiveRecord::Base
  validates :registrant_id, :presence => true
  validates :user_id, :presence => true
  validates :place, :presence => true, :numericality => {:greater_than => 0}

  belongs_to :user
  belongs_to :registrant


  def build_name_from_competitor_and_registrant(competitor, registrant)
    res = "#{registrant.first_name} #{registrant.last_name}"
    if competitor.members.count == 2
      partner = (competitor.registrants - [registrant]).first

      res += " & " + partner.first_name + " " + partner.last_name
    end
    res
  end

  def build_category_name(competitor, expert)

    if expert
      age_group = "Expert #{competitor.gender}"
    else
      if competitor.competition.has_age_groups
        age_group = competitor.age_group_entry_description
      end
    end

    if competitor.competition.include_event_name
      age_group = competitor.competition.name
    end

    if age_group == "All" # Don't display if age_group result is 'All'
      age_group = nil
    end

    if competitor.members.count > 1
      gender = nil
    else
      gender = competitor.gender
    end

    res = ""
    if age_group.present?
      res += age_group
    else
      # No Age Group?
      if gender.present?
        res += gender
      end
    end

    res
  end

  def populate_from_competitor(competitor, registrant, expert = false)

    # line 1
    self.competitor_name = build_name_from_competitor_and_registrant(competitor, registrant)

    # line 2
    if competitor.competition.include_event_name
      competition_name = competitor.competition.event.name
    else
      competition_name = competitor.competition.name # These events have been 'fully named' (don't need the 'event' name)
    end
    self.competition_name = competition_name

    # line 3
    self.team_name = competitor.team_name

    # line 4
    self.category = build_category_name(competitor, expert)

    # line 5
    self.details = competitor.result

    # line 6
    if expert
      self.place = competitor.overall_place.to_i
    else
      self.place = competitor.place.to_i
    end

    # misc housekeeping
    self.registrant = registrant
    self.bib_number = registrant.bib_number
  end

  def line_1
    self.competitor_name
  end

  def line_2
    self.competition_name
  end

  def line_3
    self.team_name
  end

  def line_4
    self.category
  end

  def line_5
    self.details
  end

  def line_6
    case self.place
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
end
