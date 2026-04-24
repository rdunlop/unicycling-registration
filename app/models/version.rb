# Used by PaperTrail Gem

# == Schema Information
#
# Table name: versions
#
#  id             :integer          not null, primary key
#  item_type      :string           not null
#  item_id        :integer          not null
#  event          :string           not null
#  whodunnit      :string
#  created_at     :datetime
#  registrant_id  :integer
#  user_id        :integer
#  object         :json
#  object_changes :json
#
# Indexes
#
#  index_versions_on_item_type_and_item_id  (item_type,item_id)
#
class Version < ApplicationRecord
  belongs_to :item, polymorphic: true
  # attr_accessible :registrant_id, :user_id
end
