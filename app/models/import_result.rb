# == Schema Information
#
# Table name: import_results
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  raw_data       :string(255)
#  bib_number     :integer
#  minutes        :integer
#  seconds        :integer
#  thousands      :integer
#  disqualified   :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  competition_id :integer
#  rank           :integer
#  details        :string(255)
#

class ImportResult < ActiveRecord::Base
  validates :competition_id, :presence => true
  validates :user_id, :presence => true
  validates :raw_data, :presence => true

  belongs_to :user
  belongs_to :competition

  default_scope { order(:bib_number) }
end
