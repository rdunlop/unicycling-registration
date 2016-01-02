# == Schema Information
#
# Table name: members
#
#  id                        :integer          not null, primary key
#  competitor_id             :integer
#  registrant_id             :integer
#  created_at                :datetime
#  updated_at                :datetime
#  dropped_from_registration :boolean          default(FALSE), not null
#  alternate                 :boolean          default(FALSE), not null
#
# Indexes
#
#  index_members_competitor_id  (competitor_id)
#  index_members_registrant_id  (registrant_id)
#

class Member < ActiveRecord::Base
  include CachedSetModel

  belongs_to :competitor, inverse_of: :members
  belongs_to :registrant
  after_destroy :destroy_orphaned_competitors

  validates :registrant, presence: true
  validate :registrant_once_per_competition

  after_touch :update_min_bib_number
  after_save :update_min_bib_number
  after_destroy :update_min_bib_number
  after_save :touch_competitor

  # This is used by the Competitor, in order to update Members
  # without cascading the change back to the Competitor.
  attr_accessor :no_touch_cascade

  def touch_competitor
    competitor.touch unless no_touch_cascade
  end

  def self.cache_set_field
    :registrant_id
  end

  def self.active
    where(alternate: false)
  end

  def update_min_bib_number
    return if no_touch_cascade
    comp = competitor(true)
    return if comp.nil?
    lowest_bib_number = comp.members.includes(:registrant).minimum("registrants.bib_number")
    competitor.update_attribute(:lowest_member_bib_number, lowest_bib_number) if lowest_bib_number
  end

  # validates :competitor, :presence => true # removed for spec tests

  def destroy_orphaned_competitors
    if competitor && competitor.members.none?
      competitor.destroy
    end
  end

  # Should we consider this member dropped?
  # Only do so if they ever dropped, and they are currrently not registered.
  def currently_dropped?
    dropped_from_registration? && !competitor.competition.signed_up_registrants.include?(registrant)
  end

  def registrant_once_per_competition
    if new_record?
      if competitor.nil? || registrant.nil?
        return
      end
      if registrant.competitors.where(competition: competitor.competition).any?
        errors[:base] = "Cannot have the same registrant (#{registrant}) in the same competition twice"
      end
    end
  end

  def to_s
    if alternate
      registrant.to_s + "(alternate)"
    else
      registrant.to_s
    end
  end

  delegate :club, :state, :country, :ineligible?, :gender, :external_id, :age, to: :registrant
end
