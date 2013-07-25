class ImportResult < ActiveRecord::Base
  attr_accessible :bib_number, :disqualified, :minutes, :raw_data, :seconds, :thousands

  validates :user_id, :presence => true
  validates :raw_data, :presence => true

  belongs_to :user

  default_scope order(:bib_number)
end
