# == Schema Information
#
# Table name: competition_sources
#
#  id                    :integer          not null, primary key
#  target_competition_id :integer
#  event_category_id     :integer
#  competition_id        :integer
#  gender_filter         :string(255)
#  max_place             :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class CompetitionSource < ActiveRecord::Base
  belongs_to :event_category, :inverse_of => :competition_sources
  belongs_to :target_competition, :class_name => "Competition", :inverse_of => :competition_sources
  belongs_to :competition

  def self.gender_filters
    ["Both", "Male", "Female"]
  end
  validates :gender_filter, :inclusion => { :in => self.gender_filters, :allow_nil => false }
  validates :target_competition, :presence => true
  validate :source_present
  validate :max_place_with_competition

  after_initialize :init

  def init
    self.gender_filter = "Both" if self.gender_filter.nil?
  end

  def source_present
    if self.event_category.nil? and self.competition.nil?
      errors[:base] << "Must select an Event Category or a Competition"
    end
  end

  def max_place_with_competition
    if self.max_place and self.competition.nil?
      errors[:base] << "Must select a Competition when setting max_place"
    end
  end

  def to_s
    target_competition.to_s + " -> " + self.competition + self.event_category
  end

  def signed_up_registrants
    unless event_category.nil?
      registrants = event_category.signed_up_registrants

    end
    unless competition.nil?
      competitors = competition.competitors
      competitors = competitors.select {|comp| comp.overall_place <= max_place } unless max_place.nil?

      registrants = competitors.map{|comp| comp.registrants }.flatten
    end
    unless gender_filter.nil? or gender_filter == "Both"
      registrants = registrants.select {|reg| reg.gender == gender_filter}
    end
    registrants
  end

end
