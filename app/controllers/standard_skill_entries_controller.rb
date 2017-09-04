# == Schema Information
#
# Table name: standard_skill_entries
#
#  id                        :integer          not null, primary key
#  number                    :integer
#  letter                    :string(255)
#  points                    :decimal(6, 2)
#  description               :string(255)
#  created_at                :datetime
#  updated_at                :datetime
#  friendly_description      :text
#  additional_description_id :integer
#  skill_speed               :string
#  skill_before_id           :integer
#  skill_after_id            :integer
#
# Indexes
#
#  index_standard_skill_entries_on_letter_and_number  (letter,number) UNIQUE
#

class StandardSkillEntriesController < ApplicationController
  before_action :skip_authorization

  # GET /standard_skill_entries
  def index
    # This should be visible to "all" (even not-logged in)
    @standard_skill_entries = StandardSkillEntry.all
  end
end
