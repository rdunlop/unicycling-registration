# == Schema Information
#
# Table name: members
#
#  id                        :integer          not null, primary key
#  competitor_id             :integer
#  registrant_id             :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  dropped_from_registration :boolean          default(FALSE)
#
# Indexes
#
#  index_members_competitor_id  (competitor_id)
#  index_members_registrant_id  (registrant_id)
#

class Member < ActiveRecord::Base
    belongs_to :competitor, touch: true, :inverse_of => :members
    belongs_to :registrant
    after_destroy :destroy_orphaned_competitors

    validates :registrant_id, :presence => true
    validate :registrant_once_per_competition

    after_save :update_min_bib_number
    after_destroy :update_min_bib_number

    def update_min_bib_number
      comp = competitor(true)
      return if comp.nil?
      lowest_bib_number = comp.members.map{ |member| member.registrant.bib_number }.min
      competitor.update_attribute(:lowest_member_bib_number, lowest_bib_number) if lowest_bib_number
    end

    #validates :competitor, :presence => true # removed for spec tests

    def destroy_orphaned_competitors
        if competitor and competitor.members.none?
            competitor.destroy
        end
    end

    def registrant_once_per_competition
        if new_record?
            if competitor.nil? or registrant.nil?
                return
            end
            competition = competitor.competition
            competition.reload.registrants.each do |reg|
                if reg == registrant
                    errors[:base] = "Cannot have the same registrant (#{registrant}) in the same competition twice"
                end
            end
        end
    end

    delegate :club, :state, :country, :ineligible, :gender, :to_s, :external_id, :age, to: :registrant
end
