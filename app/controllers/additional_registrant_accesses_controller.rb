# == Schema Information
#
# Table name: additional_registrant_accesses
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  registrant_id      :integer
#  declined           :boolean          default(FALSE), not null
#  accepted_readonly  :boolean          default(FALSE), not null
#  created_at         :datetime
#  updated_at         :datetime
#  accepted_readwrite :boolean          default(FALSE), not null
#
# Indexes
#
#  ada_reg_user                                        (registrant_id,user_id) UNIQUE
#  index_additional_registrant_accesses_registrant_id  (registrant_id)
#  index_additional_registrant_accesses_user_id        (user_id)
#

class AdditionalRegistrantAccessesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_user, only: %i[create index new invitations]
  before_action :load_additional_registrant_accesses, only: %i[create index new invitations]
  before_action :load_additional_registrant_access, except: %i[create index new invitations]
  before_action :load_new_additional_registrant_access, only: [:create]
  before_action :authorize_access, except: :new

  # GET /additional_registrant_accesses
  # GET /additional_registrant_accesses.json
  def index
    @additional_registrant_accesses = @user.additional_registrant_accesses

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @additional_registrant_accesses }
    end
  end

  # GET /users/1/additional_registrant_accesses/invitations
  def invitations
    @additional_registrant_accesses = @user.invitations
  end

  # GET /additional_registrant_accesses/new
  # GET /additional_registrant_accesses/new.json
  def new
    @additional_registrant_access = @user.additional_registrant_accesses.build
    authorize @additional_registrant_access

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @additional_registrant_access }
    end
  end

  # POST /additional_registrant_accesses
  # POST /additional_registrant_accesses.json
  def create
    respond_to do |format|
      if @additional_registrant_access.save
        Notifications.request_registrant_access(@additional_registrant_access.registrant, @user).deliver_later
        format.html { redirect_to user_additional_registrant_accesses_path(@user), notice: 'Additional registrant access request was successfully created.' }
        format.json { render json: @additional_registrant_access, status: :created, location: @additional_registrant_access }
      else
        format.html { render action: "new" }
        format.json { render json: @additional_registrant_access.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /additional_registrant_accesses/1/accept_readonly
  def accept_readonly
    @additional_registrant_access = AdditionalRegistrantAccess.find(params[:id])
    user = @additional_registrant_access.registrant.user

    respond_to do |format|
      if @additional_registrant_access.update_attributes(declined: false, accepted_readonly: true)
        Notifications.registrant_access_accepted(@additional_registrant_access.registrant, @additional_registrant_access.user).deliver_later
        format.html { redirect_to invitations_user_additional_registrant_accesses_path(user), notice: 'Additional registrant access was accepted (readonly).' }
        format.json { head :no_content }
      else
        format.html { redirect_to invitations_user_additional_registrant_accesses_path(user) }
        format.json { render json: @additional_registrant_access.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /additional_registrant_accesses/1/decline
  def decline
    @additional_registrant_access = AdditionalRegistrantAccess.find(params[:id])
    user = @additional_registrant_access.registrant.user

    respond_to do |format|
      if @additional_registrant_access.update_attributes(declined: true, accepted_readonly: false)
        format.html { redirect_to invitations_user_additional_registrant_accesses_path(user), notice: 'Request declined' }
        format.json { head :no_content }
      else
        format.html { redirect_to invitations_user_additional_registrant_accesses_path(user) }
      end
    end
  end

  private

  def authorize_access
    authorize @additional_registrant_access || AdditionalRegistrantAccess.new
  end

  def load_new_additional_registrant_access
    @additional_registrant_access = @user.additional_registrant_accesses.build(additional_registrant_access_params)
  end

  def load_additional_registrant_accesses
    @additional_registrant_accesses = @user.additional_registrant_accesses
  end

  def load_additional_registrant_access
    @additional_registrant_access = AdditionalRegistrantAccess.find(params[:id])
  end

  def load_user
    @user = User.this_tenant.find(params[:user_id])
  end

  def additional_registrant_access_params
    params.require(:additional_registrant_access).permit(:registrant_id)
  end
end
