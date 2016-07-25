# == Schema Information
#
# Table name: wheel_sizes
#
#  id          :integer          not null, primary key
#  position    :integer
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class WheelSize < ActiveRecord::Base
  validates :position, :description, presence: true

  default_scope { order("position DESC") }

  has_many :age_group_entries, dependent: :nullify
  has_many :registrants, dependent: :nullify

  def self.available_sizes
    if EventConfiguration.singleton.usa?
      all
    else
      # Hide the 16" whees size
      where.not(description: "16\" Wheel")
    end
  end

  def to_s
    description
  end
end
