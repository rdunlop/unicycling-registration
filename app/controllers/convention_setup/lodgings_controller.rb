class ConventionSetup::LodgingsController < ConventionSetup::BaseConventionSetupController
  before_action :load_lodging, except: %i[index new create]
  before_action :authorize_setup

  before_action :set_breadcrumbs

  respond_to :html

  # GET /convention_setup/lodgings
  def index
    @lodgings = Lodging.all
  end

  def new
    @lodging = Lodging.new
  end

  # GET /convention_setup/lodgings/1/edit
  def edit
    add_breadcrumb "Edit Lodging"
  end

  # POST /convention_setup/lodgings
  def create
    @lodging = Lodging.new(lodging_params)
    respond_to do |format|
      if @lodging.save
        format.html { redirect_to convention_setup_lodgings_path, notice: 'Lodging was successfully created.' }
      else
        @lodgings = Lodging.all
        flash.now[:alert] = "Unable to create lodging. #{@lodging.errors.full_messages.join(', ')}"
        format.html { render action: "index" }
      end
    end
  end

  def show
    add_breadcrumb @lodging.to_s, convention_setup_lodging_path(@lodging)
  end

  # PUT /convention_setup/lodgings/1
  def update
    respond_to do |format|
      if @lodging.update_attributes(lodging_params)
        format.html { redirect_to convention_setup_lodgings_path, notice: 'Lodging was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /convention_setup/lodgings/1
  def destroy
    if @lodging.destroy
      flash[:notice] = "Lodging deleted"
    else
      flash[:alert] = "Unable to delete lodging"
    end
    redirect_to convention_setup_lodgings_path
  end

  private

  def load_lodging
    @lodging = Lodging.find(params[:id])
  end

  def authorize_setup
    authorize @config, :setup_convention?
  end

  def set_breadcrumbs
    add_breadcrumb "Setup Lodging", convention_setup_lodgings_path
  end

  def lodging_params
    params.require(:lodging).permit(:name, :description,
                                    lodging_room_types_attributes: %i[id _destroy name description visible maximum_available])
  end
end
