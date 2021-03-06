require 'spec_helper'

describe Lodging do
  let(:lodging) { FactoryBot.create(:lodging) }

  context "destroying" do
    describe "with an lodging_type" do
      let!(:lodging_room_type) { FactoryBot.create(:lodging_room_type, lodging: lodging) }

      it "does not allow destruction" do
        expect(lodging.reload.lodging_room_types.length).to eq(1)
        expect(lodging.destroy).to be_falsey
      end
    end
  end
end

# == Schema Information
#
# Table name: lodgings
#
#  id          :bigint           not null, primary key
#  position    :integer
#  name        :string           not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  visible     :boolean          default(TRUE), not null
#
# Indexes
#
#  index_lodgings_on_visible  (visible)
#
