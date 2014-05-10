# == Schema Information
#
# Table name: event_categories
#
#  id              :integer          not null, primary key
#  event_id        :integer
#  position        :integer
#  name            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  age_range_start :integer          default(0)
#  age_range_end   :integer          default(100)
#

class EventCategory < ActiveRecord::Base
  belongs_to :event, :inverse_of => :event_categories, :touch => true

  has_many :registrant_event_sign_ups, :dependent => :destroy

  has_many :competition_sources, :dependent => :destroy

  validates :name, {:presence => true, :uniqueness => {:scope => [:event_id]} }
  validates :position, :uniqueness => {:scope => [:event_id]}

  def to_s
    event.to_s + " - " + self.name
  end

  def signed_up_registrants
    registrant_event_sign_ups.signed_up.map{|resu| resu.registrant }.select{ |reg| !reg.deleted }
  end

  def num_competitors
    signed_up_registrants.count
  end

  def age_is_in_range(age)
    return true if age.nil?

    (age_range_start..age_range_end).include?(age)
  end
end
