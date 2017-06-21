# == Schema Information
#
# Table name: registrant_group_types
#
#  id                    :integer          not null, primary key
#  source_element_type   :string           not null
#  source_element_id     :integer          not null
#  notes                 :string
#  max_members_per_group :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class RegistrantGroupTypesController < ApplicationController
  before_action :authenticate_user!

  before_action :authorize_collection
  before_action :add_breadcrumbs

  # GET /registrant_group_types
  def index
    @registrant_group_types = RegistrantGroupType.all
  end

  private

  def authorize_collection
    authorize RegistrantGroupType
  end

  def add_breadcrumbs
    add_breadcrumb "Registrant Group Types", registrant_group_types_path
  end
end
