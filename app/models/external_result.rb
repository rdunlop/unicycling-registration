# == Schema Information
#
# Table name: external_results
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  details       :string(255)
#  rank          :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_external_results_on_competitor_id  (competitor_id)
#

class ExternalResult < ActiveRecord::Base
  include Competeable
  include Placeable

  validates :rank, :presence => true

  def disqualified
    false
  end

  def result
    rank
  end
end
