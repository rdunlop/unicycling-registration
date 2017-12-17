require 'spec_helper'

describe LodgingRoomType do
  let(:lodging) { FactoryGirl.create(:lodging) }
end

# == Schema Information
#
# Table name: lodging_room_types
#
#  id                :integer          not null, primary key
#  lodging_id        :integer          not null
#  position          :integer
#  name              :string           not null
#  description       :text
#  visible           :boolean          default(TRUE), not null
#  maximum_available :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_lodging_room_types_on_lodging_id  (lodging_id)
#
