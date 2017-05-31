# == Schema Information
#
# Table name: registrant_groups
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  registrant_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_registrant_groups_registrant_id  (registrant_id)
#

class RegistrantGroupTypesController < ApplicationController
  before_action :authenticate_user!

  before_action :load_registrant_group_type, except: [:index]
  before_action :authorize_user, except: [:index]

  # GET /registrant_group_types
  def index
    authorize RegistrantGroupType
    @registrant_group_types = RegistrantGroupType.all
  end

  # GET /registrant_group_types/new
  def new
    @registrant_group_type = RegistrantGroupType.new
  end

  # GET /registrant_group_types/1
  def show
    @registrant_groups = @registrant_group_type.registrant_groups
  end

  # POST /registrant_group_types
  def create
    if @registrant_group_type.save
      redirect_to @registrant_group_type, notice: 'Registrant group type was successfully created.'
    else
      render :new
    end
  end

  # PUT /registrant_group_types/1
  def update
    if @registrant_group_type.update_attributes(registrant_group_type_params)
      redirect_to @registrant_group_type, notice: 'Registrant group type was successfully updated.'
    else
      render :show
    end
  end

  # DELETE /registrant_group_types/1
  def destroy
    @registrant_group_type.destroy

    redirect_to registrant_group_types_url
  end

  private

  def authorize_user
    authorize @registrant_group_type
  end

  def load_registrant_group_type
    @registrant_group_type = RegistrantGroupType.find(params[:id])
  end

  def registrant_group_type_params
    params.require(:registrant_group_type).permit(
      :notes,
      :source_element_type,
      :source_element_id,
      :max_members_per_group
    )
  end
end
