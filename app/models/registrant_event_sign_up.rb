# == Schema Information
#
# Table name: registrant_event_sign_ups
#
#  id                :integer          not null, primary key
#  registrant_id     :integer
#  signed_up         :boolean          default(FALSE), not null
#  event_category_id :integer
#  created_at        :datetime
#  updated_at        :datetime
#  event_id          :integer
#
# Indexes
#
#  index_registrant_event_sign_ups_event_category_id              (event_category_id)
#  index_registrant_event_sign_ups_event_id                       (event_id)
#  index_registrant_event_sign_ups_on_registrant_id_and_event_id  (registrant_id,event_id) UNIQUE
#  index_registrant_event_sign_ups_registrant_id                  (registrant_id)
#

class RegistrantEventSignUp < ActiveRecord::Base
  validates :event, :registrant, presence: true
  # validates :event_category, :presence => true, :if  => "signed_up"
  validates :signed_up, inclusion: {in: [true, false] } # because it's a boolean
  validate :category_chosen_when_signed_up
  validate :category_in_age_range
  validates :event_id, presence: true, uniqueness: {scope: [:registrant_id]}

  has_paper_trail meta: { registrant_id: :registrant_id }

  belongs_to :registrant, inverse_of: :registrant_event_sign_ups, touch: true
  belongs_to :event_category, touch: true
  belongs_to :event

  after_save :auto_create_competitor
  after_save :mark_member_as_dropped

  def self.signed_up
    includes(:registrant).where(registrants: {deleted: false}).where(signed_up: true)
  end

  def auto_create_competitor
    if signed_up
      event_category.competitions_being_fed(registrant).each do |competition|
        next unless competition.automatic_competitor_creation?
        next if registrant.competitions.include?(competition)
        competition.create_competitors_from_registrants([registrant], nil)
      end
    end
  end

  def event_category_name
    event_category.name.to_s if event.event_categories.size > 1
  end

  def mark_member_as_dropped
    # was signed up and now we are not
    if signed_up_was && signed_up_changed? && !signed_up
      ec = EventCategory.find(event_category_id_was)
      ec.competitions_being_fed(registrant).each do |competition|
        member = registrant.members.find{|mem| mem.competitor.competition == competition}
        if member
          member.update_attributes(dropped_from_registration: true)
          competitor = member.competitor
          if competitor.active? && competition.num_members_per_competitor == "One"
            competitor.update_attributes(status: "withdrawn")
          end
        end
      end
    end

    # handle changing category
    if signed_up && event_category_id_changed? && !event_category_id_was.nil?
      old_category = EventCategory.find(event_category_id_was)
      old_category.competitions_being_fed(registrant).each do |competition|
        member = registrant.members.find{|mem| mem.competitor.try(:competition) == competition}
        member.update_attributes(dropped_from_registration: true) if member
        # NOTE: This is the same as the above function. wtf robin
        competitor = member.competitor
        if competitor.active? && competition.num_members_per_competitor == "One"
          competitor.update_attributes(status: "withdrawn")
        end
      end
    end
  end

  def category_chosen_when_signed_up
    if signed_up && event_category.nil?
      errors[:base] << "Cannot sign up for #{event.name} without choosing a category"
    end
  end

  def category_in_age_range
    unless event_category.nil? || registrant.nil?
      if signed_up && !(event_category.age_is_in_range(registrant.age))
        errors[:base] << "You must be between #{event_category.age_range_start} and #{event_category.age_range_end}
        years old to select #{event_category.name} for #{event.name} in #{event.category}"
      end
    end
  end

  delegate :to_s, to: :event_category
end
