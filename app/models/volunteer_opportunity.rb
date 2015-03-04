# == Schema Information
#
# Table name: volunteer_opportunities
#
#  id            :integer          not null, primary key
#  description   :string(255)
#  display_order :integer
#  inform_emails :text
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_volunteer_opportunities_on_description    (description) UNIQUE
#  index_volunteer_opportunities_on_display_order  (display_order)
#

class VolunteerOpportunity < ActiveRecord::Base
  validates :description, :display_order, presence: true
  validates :description, uniqueness: true

  default_scope { order(:display_order) }

  has_many :volunteer_choices, dependent: :destroy

  def to_s
    description
  end
end
