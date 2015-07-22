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
#  created_at       :datetime
#  updated_at       :datetime
#  competitor_name  :string(255)
#  category         :string(255)
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

  private
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
      if competitor.members.count > 1
        "Expert"
      else
        "Expert #{competitor.gender}"
      end
    else
      if competitor.competition.age_group_type.present?
        competitor.age_group_entry_description
      else
        competitor.competition.award_subtitle_name
      end
    end
  end

  def compare(str1, str2)
    raise("#{str1} != #{str2}") if str1 != str2
  end

  def find_result(competitor, expert)
    if expert || !competitor.competition.has_age_group_entry_results?
      competitor.results.overall.first
    else
      competitor.results.age_group.first
    end
  end

  public
  def populate_from_competitor(competitor, registrant, place, expert = false)
    result = find_result(competitor, expert)

    # Temporary code to ensure we are identical to the old system:
    compare(result.competitor_name(registrant), build_name_from_competitor_and_registrant(competitor, registrant))
    compare(result.competition_name, competitor.competition.award_title_name)
    compare(result.team_name, competitor.team_name)
    compare(result.category_name, build_category_name(competitor, expert))
    compare(result.details, competitor.result)
    compare(result.place, place)

    self.competitor_name = result.competitor_name(registrant)
    self.competition_name = result.competition_name
    self.team_name = result.team_name
    self.category = result.category_name
    self.details = result.details
    self.place = result.place

    # # line 1
    # self.competitor_name = build_name_from_competitor_and_registrant(competitor, registrant)

    # # line 2
    # self.competition_name = competitor.competition.award_title_name

    # # line 3
    # self.team_name = competitor.team_name

    # # line 4
    # self.category = build_category_name(competitor, expert)

    # # line 5
    # self.details = competitor.result

    # # line 6
    # self.place = place

    # misc housekeeping
    self.registrant = registrant
    self.bib_number = registrant.bib_number
  end

  def line_1
    competitor_name
  end

  def line_2
    competition_name
  end

  def line_3
    team_name
  end

  def line_4
    category
  end

  def line_5
    details
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
end
