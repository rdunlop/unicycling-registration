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
#  min_age               :integer
#  max_age               :integer
#
# Indexes
#
#  index_competition_sources_competition_id         (competition_id)
#  index_competition_sources_event_category_id      (event_category_id)
#  index_competition_sources_target_competition_id  (target_competition_id)
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

  # XXX this needs cachnig somehow.
  def signed_up_registrants
    registrants = []
    if event_category.present?
      registrants = event_category.signed_up_registrants
    end

    if competition.present?
      competitors = competition.competitors
      competitors = competitors.select {|comp| comp.overall_place.to_i > 0 && comp.overall_place.to_i <= max_place } unless max_place.nil?

      registrants = competitors.map{|comp| comp.registrants }.flatten
    end

    if gender_filter.present? && gender_filter != "Both"
      registrants = registrants.select {|reg| reg.gender == gender_filter}
    end

    if min_age || max_age
      min = min_age || 0
      max = max_age || 999
      registrants = registrants.select {|reg| reg.age >= min && reg.age <= max }
    end

    registrants
  end
end
