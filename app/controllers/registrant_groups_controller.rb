# == Schema Information
#
# Table name: registrant_groups
#
#  id                       :integer          not null, primary key
#  name                     :string
#  created_at               :datetime
#  updated_at               :datetime
#  registrant_group_type_id :integer
#
# Indexes
#
#  index_registrant_groups_on_registrant_group_type_id  (registrant_group_type_id)
#

class RegistrantGroupsController < ApplicationController
  before_action :authenticate_user!

  before_action :load_registrant_group_type, only: %i[index new create]
  before_action :load_registrant_group, except: %i[index new create]
  before_action :authorize_user, except: %i[index new create]

  # GET /registrant_group_types/:id/registrant_groups
  def index
    authorize RegistrantGroup
    @registrant_groups = @registrant_group_type.registrant_groups.all
  end

  # GET /registrant_group_types/:id/registrant_groups/new
  def new
    @registrant_group = RegistrantGroup.new
    authorize @registrant_group
  end

  def create
    @registrant_group = RegistrantGroup.new(registrant_group_params)
    @registrant_group.registrant_group_type = @registrant_group_type
    authorize @registrant_group
    if @registrant_group.save
      flash[:notice] = "Group created"
      redirect_to @registrant_group
    else
      flash.now[:alert] = "Error creating group"
      render :new
    end
  end

  # update the name of the group
  def edit; end

  # GET /registrant_groups/1
  def show
    type = @registrant_group.registrant_group_type
    add_breadcrumb "Registrant Groups: #{type}", registrant_group_type_registrant_groups_path(type)
    @registrant_group_members = @registrant_group.registrant_group_members
    @registrant_group_leaders = @registrant_group.registrant_group_leaders
  end

  # PUT /registrant_groups/1
  def update
    if @registrant_group.update_attributes(registrant_group_params)
      redirect_to @registrant_group, notice: 'Registrant group was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /registrant_groups/1
  def destroy
    @registrant_group.destroy

    redirect_to registrant_group_type_registrant_groups_path(@registrant_group.registrant_group_type)
  end

  private

  def authorize_user
    authorize @registrant_group
  end

  def load_registrant_group_type
    @registrant_group_type = RegistrantGroupType.find(params[:registrant_group_type_id])
  end

  def load_registrant_group
    @registrant_group = RegistrantGroup.find(params[:id])
  end

  def load_new_registrant_group
    @registrant_group = RegistrantGroup.new(registrant_group_params)
  end

  def registrant_group_params
    params.require(:registrant_group).permit(:name,
                                             registrant_group_members_attributes: %i[registrant_id _destroy id])
  end
end
