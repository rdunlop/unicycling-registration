require 'spec_helper'

describe Lodging do
  let(:lodging) { FactoryGirl.create(:lodging) }

  context "destroying" do
    describe "with an lodging_type" do
      let!(:lodging_room_type) { FactoryGirl.create(:lodging_room_type, lodging: lodging) }
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
#  id          :integer          not null, primary key
#  name        :string           not null
#  position    :integer
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
