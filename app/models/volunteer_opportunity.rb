# == Schema Information
#
# Table name: volunteer_opportunities
#
#  id            :integer          not null, primary key
#  description   :string(255)
#  position      :integer
#  inform_emails :text
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_volunteer_opportunities_on_description  (description) UNIQUE
#  index_volunteer_opportunities_on_position     (position)
#

class VolunteerOpportunity < ActiveRecord::Base
  validates :description, presence: true
  validates :description, uniqueness: true

  acts_as_restful_list

  default_scope { order(:position) }

  has_many :volunteer_choices, dependent: :destroy

  def to_s
    description
  end
end
