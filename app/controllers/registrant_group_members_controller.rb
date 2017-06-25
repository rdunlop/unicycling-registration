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

class RegistrantGroupMembersController < ApplicationController
  before_action :authenticate_user!

  before_action :load_registrant_group_member, only: %i[promote request_leader destroy]
  before_action :authorize_registrant_group_member, only: %i[promote request_leader destroy]
  before_action :load_registrant_group, only: %i[create]

  def create
    @registrant_group_member = @registrant_group.registrant_group_members.build(registrant_group_member_params)
    authorize @registrant_group_member
    if @registrant_group_member.save
      flash[:notice] = "Created Group Member"
    else
      flash[:alert] = "Error creating member"
    end
    redirect_to registrant_group_path(@registrant_group_member.registrant_group)
  end

  # DELETE /registrant_group_members/1
  def destroy
    if @registrant_group_member.destroy
      flash[:notice] = "Deleted Member"
    else
      flash[:alert] = "Error removing member"
    end

    redirect_to registrant_group_path(@registrant_group_member.registrant_group)
  end

  # POST /registrant_group_members/1/promote
  def promote
    @registrant_group = @registrant_group_member.registrant_group
    if RegistrantGroupManager.new(@registrant_group).promote(@registrant_group_member)
      flash[:alert] = "Unable to promote member"
    else
      flash[:notice] = "Promoted Member to Leader"
    end

    redirect_to @registrant_group
  end

  # POST /registrant_group_members/1/request_leader
  def request_leader
    @registrant_group = @registrant_group_member.registrant_group
    if RegistrantGroupManager.new(@registrant_group).request_leader(@registrant_group_member)
      flash[:alert] = "Unable to request leader"
    else
      flash[:notice] = "Requested leader for group"
    end

    redirect_to @registrant_group
  end

  private

  def authorize_registrant_group_member
    authorize @registrant_group_member
  end

  def load_registrant_group_member
    @registrant_group_member = RegistrantGroupMember.find(params[:id])
  end

  def load_registrant_group
    @registrant_group = RegistrantGroup.find(params[:registrant_group_id])
  end

  def registrant_group_member_params
    params.require(:registrant_group_member).permit(:registrant_id)
  end
end
