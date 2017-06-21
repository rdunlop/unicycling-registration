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

class RegistrantGroupLeadersController < ApplicationController
  before_action :authenticate_user!

  before_action :load_registrant_group_leader, only: %i[destroy]
  before_action :load_registrant_group, only: %i[create]

  def create
    @registrant_group_leader = @registrant_group.registrant_group_leaders.build(registrant_group_leader_params)
    authorize @registrant_group_leader

    if @registrant_group_leader.save
      flash[:notice] = "Added Leader"
    else
      flash[:alert] = "Unable to add leader"
    end
    redirect_to registrant_group_path(@registrant_group)
  end

  # DELETE /registrant_group_leaders/1
  def destroy
    authorize @registrant_group_leader
    if @registrant_group_leader.destroy
      flash[:notice] = "Removed Leader"
    else
      flash[:alert] = "Unable to remove leader"
    end
    redirect_to registrant_group_path(@registrant_group_leader.registrant_group)
  end

  private

  def load_registrant_group_leader
    @registrant_group_leader = RegistrantGroupLeader.find(params[:id])
  end

  def load_registrant_group
    @registrant_group = RegistrantGroup.find(params[:registrant_group_id])
  end

  def registrant_group_leader_params
    params.require(:registrant_group_leader).permit(:user_id)
  end
end
