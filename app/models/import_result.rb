class ImportResult < ActiveRecord::Base
  attr_accessible :bib_number, :disqualified, :minutes, :raw_data, :seconds, :thousands, :competition_id, :rank, :details

  validates :competition_id, :presence => true
  validates :user_id, :presence => true
  validates :raw_data, :presence => true

  belongs_to :user
  belongs_to :competition

  default_scope order(:bib_number)
end
