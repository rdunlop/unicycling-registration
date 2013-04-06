class AdditionalRegistrantAccess < ActiveRecord::Base
  attr_accessible :accepted_readonly, :declined, :registrant_id, :user_id

  belongs_to :registrant
  belongs_to :user
  validates :user, :registrant, :presence => true

  after_initialize :init

  def init
    self.accepted_readonly = false if self.accepted_readonly.nil?
    self.declined = false if self.declined.nil?
  end
end
