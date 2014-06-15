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
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  wheel_size_id     :integer
#
# Indexes
#
#  index_age_group_entries_age_group_type_id  (age_group_type_id)
#  index_age_group_entries_wheel_size_id      (wheel_size_id)
#

class AgeGroupEntry < ActiveRecord::Base
  validates :age_group_type, :short_description, :presence => true
  validates :short_description, :uniqueness => {:scope => :age_group_type_id}
  validates :gender, :inclusion => {:in => %w(Male Female Mixed), :message => "%{value} must be either 'Male', 'Female' or 'Mixed'"}

  belongs_to :age_group_type, :touch => true, inverse_of: :age_group_entries
  belongs_to :wheel_size

  default_scope { order(:short_description) }

  # possibly replace this with override serializable hash (https://github.com/rails/rails/pull/2200)
  def as_json(options={})
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
