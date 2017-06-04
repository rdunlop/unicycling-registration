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

class RegistrantGroupsController < ApplicationController
  before_action :authenticate_user!

  before_action :load_registrant_group, except: [:index]
  before_action :authorize_user, except: [:index]

  # GET /registrant_groups
  def index
    authorize RegistrantGroup
    @registrant_groups = RegistrantGroup.all
  end

  # GET /registrant_groups/new
  def new
    @registrant_group = RegistrantGroup.new
  end

  def edit; end

  # GET /registrant_groups/1
  def show; end

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

    redirect_to registrant_groups_url
  end

  # POST /registrant_groups/1/join
  def join
    if true
      flash[:alert] = "Unable to join group"
    else
      flash[:notice] = "Joined Group"
    end

    redirect_to @registrant_group
  end

  # POST /registrant_groups/1/add_member
  def add_member
    if true
      flash[:alert] = "Unable to add member"
    else
      flash[:notice] = "Added Member to Group"
    end

    redirect_to @registrant_group
  end

  # DELETE /registrant_groups/1/remove_member
  def remove_member
    if true
      flash[:alert] = "Unable to remove member"
    else
      flash[:notice] = "Removed Member from Group"
    end

    redirect_to @registrant_group
  end

  # POST /registrant_groups/1/promote
  def promote
    if true
      flash[:alert] = "Unable to promote member"
    else
      flash[:notice] = "Promoted Member to Leader"
    end

    redirect_to @registrant_group
  end

  # DELETE /registrant_groups/1/leave
  def leave
    if true
      flash[:alert] = "Unable to leave group"
    else
      flash[:notice] = "Left Group"
    end

    redirect_to registrant_groups_path
  end

  # POST /registrant_groups/1/request_leader
  def request_leader
    if true
      flash[:alert] = "Unable to request leader"
    else
      flash[:notice] = "Requested leader for group"
    end

    redirect_to @registrant_group
  end

  private

  def authorize_user
    authorize @registrant_group
  end

  def load_registrant_group
    @registrant_group = RegistrantGroup.find(params[:id])
  end

  def load_new_registrant_group
    @registrant_group = RegistrantGroup.new(registrant_group_params)
  end

  def registrant_group_params
    params.require(:registrant_group).permit(:name, :registrant_id,
                                             registrant_group_members_attributes: %i[registrant_id _destroy id])
  end
end
