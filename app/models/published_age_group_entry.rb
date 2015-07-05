# == Schema Information
#
# Table name: published_age_group_entries
#
#  id                 :integer          not null, primary key
#  competition_id     :integer
#  age_group_entry_id :integer
#  published_at       :datetime
#  created_at         :datetime
#  updated_at         :datetime
#

class PublishedAgeGroupEntry < ActiveRecord::Base
  belongs_to :competition, touch: true
  belongs_to :age_group_entry

  before_create :set_published_at_date

  delegate :to_s, to: :age_group_entry

  def published_formatted
    published_at.to_formatted_s(:short)
  end

  private

  def set_published_at_date
    self.published_at = DateTime.now
  end
end
