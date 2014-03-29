# == Schema Information
#
# Table name: registrant_event_sign_ups
#
#  id                :integer          not null, primary key
#  registrant_id     :integer
#  signed_up         :boolean
#  event_category_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  event_id          :integer
#

class RegistrantEventSignUp < ActiveRecord::Base
  validates :event, :registrant, :presence => true
  #validates :event_category, :presence => true, :if  => "signed_up"
  validates :signed_up, :inclusion => {:in => [true, false] } # because it's a boolean
  validate :category_chosen_when_signed_up
  validate :category_in_age_range
  validates :event_id, :presence => true, :uniqueness => {:scope => [:registrant_id]}

  has_paper_trail :meta => { :registrant_id => :registrant_id }

  belongs_to :registrant, :inverse_of => :registrant_event_sign_ups
  belongs_to :event_category
  belongs_to :event

  def category_chosen_when_signed_up
    if self.signed_up and self.event_category.nil?
      errors[:base] << "Cannot sign up for #{self.event.name} without choosing a category"
    end
  end

  def category_in_age_range
    unless self.event_category.nil? or registrant.nil?
      if self.signed_up and !(self.event_category.age_is_in_range(registrant.age))
        errors[:base] << "You must be between #{self.event_category.age_range_start} and #{self.event_category.age_range_end} 
        years old to select #{self.event_category.name} for #{self.event.name} in #{self.event.category}"
      end
    end
  end

  def to_s
    self.event_category.to_s
  end
end
