# == Schema Information
#
# Table name: competitors
#
#  id                       :integer          not null, primary key
#  competition_id           :integer
#  position                 :integer
#  custom_name              :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  status                   :integer          default(0)
#  lowest_member_bib_number :integer
#  geared                   :boolean          default(FALSE), not null
#  riding_wheel_size        :integer
#  notes                    :string(255)
#  wave                     :integer
#  riding_crank_size        :integer
#
# Indexes
#
#  index_competitors_event_category_id  (competition_id)
#

require 'spec_helper'

describe Example::CompetitionChoicesController do
  actions = [
    :index,
    :freestyle,
    :individual,
    :pairs,
    :group,
    :standard_skill,
    :high_long,
    :timed,
    :points,
    :flatland,
    :street,
    :overall_champion,
    :custom
  ]

  context "as public" do
    actions.each do |action|
      it "renders successfully" do
        get action
        expect(response).to be_success
      end
    end

    it "can download a file" do
      get :download_file, filename: "heat_01.lif"
      expect(response).to be_success
    end
  end

  context "as admin" do
    before do
      @ev = FactoryGirl.create(:event)
      sign_in FactoryGirl.create(:competition_admin_user)
    end

    actions.each do |action|
      it "renders successfully" do
        get action
        expect(response).to be_success
      end
    end

    it "can download a file" do
      get :download_file, filename: "heat_01.lif"
      expect(response).to be_success
    end
  end
end
