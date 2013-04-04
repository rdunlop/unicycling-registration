class AgeGroupEntry < ActiveRecord::Base
  attr_accessible :age_group_type_id, :end_age, :gender, :long_description, :short_description, :start_age, :wheel_size_id

  belongs_to :age_group_type, :touch => true

  validates :age_group_type, :presence => true
  validates :short_description, :presence => true
  validates :gender, :inclusion => {:in => %w(Male Female Mixed), :message => "%{value} must be either 'Male', 'Female' or 'Mixed'"}

  belongs_to :wheel_size

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
    short_description
  end
end
