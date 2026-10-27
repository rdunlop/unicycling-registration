# == Schema Information
#
# Table name: age_group_entries
#
#  id                :integer          not null, primary key
#  age_group_type_id :integer
#  short_description :string
#  start_age         :integer
#  end_age           :integer
#  gender            :string
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
  include AgeGroupMatching

  validates :age_group_type, :short_description, :start_age, :end_age, presence: true
  validates :start_age, :end_age, numericality: { greater_than_or_equal_to: 0 }
  validates :short_description, uniqueness: { scope: :age_group_type_id }
  validates :gender, inclusion: { in: %w[Male Female Mixed], message: "%{value} must be either 'Male', 'Female' or 'Mixed'" }

  belongs_to :age_group_type, touch: true, inverse_of: :age_group_entries
  belongs_to :wheel_size, optional: true
  has_many :age_group_combination_entries

  # The age group type is shared by competitions, whose combinations rely on its entries
  before_save :ensure_age_group_type_not_combined, if: :locked_changes?
  before_destroy :ensure_age_group_type_not_combined

  acts_as_list scope: :age_group_type

  default_scope { order(:position) }

  # An uncombined entry is its own age group
  def age_group_entry_ids
    [id]
  end

  def age_group_entries
    [self]
  end

  def to_age_group_param
    "entry-#{id}"
  end

  # Changes which are forbidden while the age group type is combined
  # (including reordering)
  def locked_changes?
    new_record? || (changed - %w[updated_at]).any?
  end

  # possibly replace this with override serializable hash (https://github.com/rails/rails/pull/2200)
  def as_json(options = {})
    options ||= {}
    options[:except] = %i[id age_group_type_id created_at updated_at wheel_size_id]
    options[:methods] = [:wheel_size_name]
    super(options)
  end

  def wheel_size_name
    wheel_size&.to_s
  end

  def to_s
    [short_description, wheel_size_name].compact.join(", ")
  end

  private

  def ensure_age_group_type_not_combined
    return unless age_group_type&.combined?

    errors.add(:base, age_group_type.combined_error)
    throw :abort
  end
end
