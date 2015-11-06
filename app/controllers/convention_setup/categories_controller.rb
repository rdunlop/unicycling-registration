class ConventionSetup::CategoriesController < ConventionSetupController
  include SortableObject

  before_action :authorize_setup
  before_action :load_category, except: [:index, :create]
  before_action :set_categories_breadcrumb

  # GET /categories
  # GET /categories.json
  def index
    @categories = Category.all
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = Category.new(category_params)
    respond_to do |format|
      if @category.save
        format.html { redirect_to convention_setup_categories_path, notice: 'Category was successfully created.' }
      else
        @categories = Category.all
        format.html { render action: "index" }
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.json
  def update
    respond_to do |format|
      if @category.update_attributes(category_params)
        format.html { redirect_to convention_setup_categories_path, notice: 'Category was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category.destroy

    redirect_to [:convention_setup, @category]
  end

  private

  def authorize_setup
    authorize @config, :setup_convention?
  end

  def load_category
    @category = Category.find(params[:id])
  end

  def sortable_object
    @sortable_object ||= Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :info_url, :info_page_id,
                                     translations_attributes: [:id, :locale, :name])
  end
end
