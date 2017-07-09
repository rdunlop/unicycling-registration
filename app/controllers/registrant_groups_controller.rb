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
    @all_registrant_groups = @registrant_group_type.registrant_groups.all
    @registrants = current_user.registrants
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
      new_leader = @registrant_group.registrant_group_leaders.build
      new_leader.user = current_user
      new_leader.save!
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
    @registrant_group_type = @registrant_group.registrant_group_type
    add_breadcrumb "Registrant Group Types", registrant_group_types_path
    add_breadcrumb "Registrant Groups: #{@registrant_group_type}", registrant_group_type_registrant_groups_path(@registrant_group_type)
    @registrant_group_members = @registrant_group.registrant_group_members
    @registrant_group_leaders = @registrant_group.registrant_group_leaders

    @new_registrant_group_member = RegistrantGroupMember.new(registrant_group: @registrant_group)
    @new_registrant_group_leader = RegistrantGroupLeader.new(registrant_group: @registrant_group)

    event = @registrant_group.registrant_group_type.source_element
    if params[:show_all_registrants]
      @show_all_registrants = true
      @new_member_registrants = Registrant.active.competitor
    else
      @show_all_registrants = false
      @new_member_registrants = current_user.registrants
    end
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
    if @registrant_group.destroy
      flash[:notice] = "Group deleted"
    end

    redirect_to registrant_group_type_registrant_groups_path(@registrant_group.registrant_group_type)
  end

  # is the registrant eligible to be in this group type?
  def registrant_eligible_for?(registrant, registrant_group_type)
    registrant.has_event?(registrant_group_type.source_element)
  end
  helper_method :registrant_eligible_for?

  # list the registrant group for which this registrant is a member IN THIS GROUP TYPE
  def registrant_group_for(registrant, registrant_group_type)
    registrant.registrant_groups.merge(registrant_group_type.registrant_groups).first
  end
  helper_method :registrant_group_for

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
