# == Schema Information
#
# Table name: age_group_entries
#
#  id                :integer          not null, primary key
#  age_group_type_id :integer
#  short_description :string(255)
#  start_age         :integer
#  end_age           :integer
#  gender            :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  wheel_size_id     :integer
#  position          :integer
#
# Indexes
#
#  age_type_desc                              (age_group_type_id,short_description) UNIQUE
#  index_age_group_entries_age_group_type_id  (age_group_type_id)
#  index_age_group_entries_wheel_size_id      (wheel_size_id)
#

class AgeGroupEntry < ApplicationRecord
  validates :age_group_type, :short_description, :start_age, :end_age, presence: true
  validates :start_age, :end_age, numericality: {greater_than_or_equal_to: 0}
  validates :short_description, uniqueness: {scope: :age_group_type_id}
  validates :gender, inclusion: {in: %w(Male Female Mixed), message: "%{value} must be either 'Male', 'Female' or 'Mixed'"}

  belongs_to :age_group_type, touch: true, inverse_of: :age_group_entries
  belongs_to :wheel_size

  acts_as_restful_list scope: :age_group_type

  default_scope { order(:position) }

  def number_matching_registrant(registrant_data)
    matching_entries = registrant_data.select do |element|
      element[:gender] == gender &&
        start_age <= element[:age] &&
        element[:age] <= end_age
    end

    matching_entries.sum {|element| element[:count] }
  end

  def smallest_neighbour(registrant_data)
    entries = age_group_type.age_group_entries_by_age_gender.where(wheel_size_id: wheel_size_id, gender: gender)
    current_index = entries.find_index self

    earlier_neighbour = entries[current_index - 1]
    next_neighbour = entries[current_index + 1]
    if current_index == 0
      # first entry has no earlier neighbour
      return next_neighbour
    elsif current_index == entries.count - 1
      # last entry has hon next neighbour
      return earlier_neighbour
    end

    if earlier_neighbour.number_matching_registrant(registrant_data) < next_neighbour.number_matching_registrant(registrant_data)
      earlier_neighbour
    else
      next_neighbour
    end
  end

  # possibly replace this with override serializable hash (https://github.com/rails/rails/pull/2200)
  def as_json(options = {})
    options ||= {}
    options[:except] = [:id, :age_group_type_id, :created_at, :updated_at, :wheel_size_id]
    options[:methods] = [:wheel_size_name]
    super(options)
  end

  def wheel_size_name
    wheel_size.to_s unless wheel_size.nil?
  end

  def to_s
    unless wheel_size_name.nil?
      return short_description + ", #{wheel_size_name}"
    end
    short_description
  end
end
