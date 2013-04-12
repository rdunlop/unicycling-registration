class AdditionalRegistrantAccessesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :user, :only => [:create, :index, :new, :invitations]
  load_and_authorize_resource :additional_registrant_access, :through => :user, :only => [:create, :index, :new, :invitations]
  load_and_authorize_resource :except => [:create, :index, :new, :invitations]

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
    @additional_registrant_access = AdditionalRegistrantAccess.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @additional_registrant_access }
    end
  end

  # POST /additional_registrant_accesses
  # POST /additional_registrant_accesses.json
  def create
    @additional_registrant_access = @user.additional_registrant_accesses.build(params[:additional_registrant_access])

    respond_to do |format|
      if @additional_registrant_access.save
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
      if @additional_registrant_access.update_attributes({:accepted_readonly => true })
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
      if @additional_registrant_access.update_attributes({:declined => true})
        format.html { redirect_to invitations_user_additional_registrant_accesses_path(user), notice: 'Request declined' }
        format.json { head :no_content }
      else
        format.html { redirect_to invitations_user_additional_registrant_accesses_path(user) }
      end
    end
  end
end
