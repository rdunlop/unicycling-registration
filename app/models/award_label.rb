class AwardLabel < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  attr_accessible :age_group, :bib_number, :competition_name, :details, :first_name, :gender, :last_name, :partner_first_name, :partner_last_name, :place, :registrant_id, :team_name, :user_id

  validates :registrant_id, :presence => true
  validates :user_id, :presence => true
  validates :place, :presence => true, :numericality => {:greater_than => 0} 

  belongs_to :user
  belongs_to :registrant


  def populate_from_competitor(competitor, registrant, expert = false)

    # line 1
    self.first_name = registrant.first_name
    self.last_name = registrant.last_name
    if competitor.members.count == 2
      reg1 = competitor.members.first.registrant
      reg2 = competitor.members.last.registrant
      if reg1 == registrant
        reg = reg2
      else
        reg = reg1
      end
      self.partner_first_name = reg.first_name
      self.partner_last_name = reg.last_name
    end

    # line 2
    if competitor.competition.event_class == "Distance" or competitor.competition.event_class == "Ranked"
      competition_name = competitor.competition.name # These events have been 'fully named' (don't need the 'event' name)
    else
      competition_name = competitor.competition.event.name
    end
    self.competition_name = competition_name

    # line 3
    self.team_name = competitor.team_name
    # line 4
    if expert
      self.age_group = "Expert #{competitor.gender}"
    else
      if competitor.competition.has_age_groups
        self.age_group = competitor.age_group_entry_description
      end
    end
    if competitor.competition.event_class == "Freestyle" ### XXX Somewhere else?
      self.age_group = competitor.competition.name # the "Category"
    end
    if self.age_group == "All" # Don't display if age_group result is 'All'
      self.age_group = nil
    end
    if competitor.members.count > 1
      self.gender = nil
    else
      self.gender = competitor.gender
    end

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
    res = "#{self.first_name} #{self.last_name}"
    unless self.partner_first_name.nil? or self.partner_first_name.blank?
      res += " & " + self.partner_first_name + " " + self.partner_last_name
    end
    res
  end

  def line_2
    self.competition_name
  end

  def line_3
    self.team_name
  end

  def line_4
    res = ""
    unless self.age_group.nil? or self.age_group.empty?
      res += self.age_group
    else
      # No Age Group?
      unless self.gender.nil? or self.gender.empty?
        res += self.gender
      end
    end
    res
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
