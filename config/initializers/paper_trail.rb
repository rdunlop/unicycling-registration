PaperTrail.config.track_associations = false

class Version < ApplicationRecord
  belongs_to :item, polymorphic: true
  # attr_accessible :registrant_id, :user_id
end
