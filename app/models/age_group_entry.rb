class AgeGroupEntry < ActiveRecord::Base
  attr_accessible :age_group_type_id, :end_age, :gender, :long_description, :short_description, :start_age

  belongs_to :age_group_type

  validates :age_group_type, :presence => true
  validates :short_description, :presence => true
  validates :gender, :inclusion => {:in => %w(Male Female Mixed), :message => "%{value} must be either 'Male', 'Female' or 'Mixed'"}

end
