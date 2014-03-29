class ExternalResult < ActiveRecord::Base
  include Competeable
  validates :rank, :presence => true
end
