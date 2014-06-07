# == Schema Information
#
# Table name: members
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  registrant_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_members_competitor_id  (competitor_id)
#  index_members_registrant_id  (registrant_id)
#

class Member < ActiveRecord::Base
    belongs_to :competitor, :touch => true, :inverse_of => :members
    belongs_to :registrant
    after_destroy :destroy_orphaned_competitors

    validates :registrant_id, :presence => true
    validate :registrant_once_per_event

    #validates :competitor, :presence => true # removed for spec tests

    def destroy_orphaned_competitors
        if competitor and competitor.registrants.empty?
            competitor.destroy
        end
    end

    def registrant_once_per_event
        if new_record?
            if competitor.nil? or registrant.nil?
                return
            end
            competition = competitor.competition
            competition.registrants.each do |reg|
                if reg == registrant
                    errors[:base] = "Cannot have the same registrant (#{registrant}) in the same competition twice"
                end
            end
        end
    end
end
