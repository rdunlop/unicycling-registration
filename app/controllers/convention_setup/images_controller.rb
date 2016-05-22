class ConventionSetup::ImagesController < ConventionSetup::BaseConventionSetupController
  before_action :load_page
  before_action :load_images
  before_action :load_image, only: [:destroy]
  before_action :authorize_setup

  before_action :set_breadcrumbs

  respond_to :html

  # GET /convention_setup/pages/:id/images
  def index
    @image = PageImage.new
  end

  # POST /convention_setup/pages/:id/images
  def create
    @image = @page.images.build
    if params[:page_image]
      @image.name = params[:page_image][:name]
      @image.image = params[:page_image][:file]
    end

    if @image.save
      flash[:notice] = 'Image was successfully created.'
      redirect_to convention_setup_page_images_path(@page)
    else
      render :index
    end
  end

  # DELETE /event_choices/1
  def destroy
    @image.destroy
    flash[:notice] = "Image was successfully deleted"

    redirect_to convention_setup_page_images_path(@page)
  end

  private

  def authorize_setup
    authorize @config, :setup_convention?
  end

  def set_breadcrumbs
    add_breadcrumb "Pages", convention_setup_pages_path
    add_breadcrumb "#{@page} Page", convention_setup_page_path(@page)
    add_breadcrumb "Images", convention_setup_page_images_path(@page)
  end

  def load_page
    @page = Page.find(params[:page_id])
  end

  def load_images
    @images = @page.images
  end

  def load_image
    @image = @page.images.find(params[:id])
  end
end
