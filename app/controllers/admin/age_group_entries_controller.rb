class Admin::AgeGroupEntriesController < Admin::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource :except => [:create]
  before_filter :load_age_group_type, :only => [:index, :create]
  before_filter :load_new_age_group_entry, :only => [:create]

  def load_age_group_type
    @age_group_type = AgeGroupType.find(params[:age_group_type_id])
  end

  def load_new_age_group_entry
    @age_group_entry = @age_group_type.age_group_entries.new(age_group_entry_params)
  end

  # GET /age_group_types/1//age_group_entries
  # GET /age_group_types/1//age_group_entries.json
  def index
    @age_group_entries = @age_group_type.age_group_entries
    @age_group_entry = AgeGroupEntry.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @age_group_entries }
    end
  end

  # GET /age_group_entries/1
  # GET /age_group_entries/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @age_group_entry }
    end
  end

  # GET /age_group_entries/1/edit
  def edit
  end

  # POST /age_group_entries
  # POST /age_group_entries.json
  def create
    authorize! :create, @age_group_entry
    age_group_type = @age_group_entry.age_group_type

    respond_to do |format|
      if @age_group_entry.save
        format.html { redirect_to admin_age_group_type_age_group_entries_path(age_group_type), notice: 'Age group entry was successfully created.' }
        format.json { render json: @age_group_entry, status: :created, location: @age_group_entry }
      else
        @age_group_entries = @age_group_type.age_group_entries
        format.html { render action: "index" }
        format.json { render json: @age_group_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /age_group_entries/1
  # PUT /age_group_entries/1.json
  def update
    age_group_type = @age_group_entry.age_group_type

    respond_to do |format|
      if @age_group_entry.update_attributes(age_group_entry_params)
        format.html { redirect_to admin_age_group_type_age_group_entries_path(age_group_type), notice: 'Age group entry was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @age_group_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /age_group_entries/1
  # DELETE /age_group_entries/1.json
  def destroy
    age_group_type = @age_group_entry.age_group_type
    @age_group_entry.destroy

    respond_to do |format|
      format.html { redirect_to admin_age_group_type_age_group_entries_path(age_group_type) }
      format.json { head :no_content }
    end
  end

  private
  def age_group_entry_params
    params.require(:age_group_entry).permit(:end_age, :gender, :long_description, :short_description, :start_age, :wheel_size_id)
  end
end
