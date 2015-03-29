class ConventionSetup::CategoriesController < ConventionSetupController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :set_categories_breadcrumb

  # GET /categories
  # GET /categories.json
  def index
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  # POST /categories.json
  def create
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

  def category_params
    params.require(:category).permit(:name, :position, :info_url,
                                     :translations_attributes => [:id, :locale, :name])
  end
end
