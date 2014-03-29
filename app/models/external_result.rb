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

class ExternalResult < ActiveRecord::Base
  include Competeable
  validates :rank, :presence => true
end
