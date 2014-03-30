class CategoriesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  respond_to :html

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
    if @category.save
      flash[:notice] = 'Category was successfully created.'
    else
      @categories = Category.all
    end

    respond_with(@category, location: categories_path, action: "index")
  end

  # PUT /categories/1
  # PUT /categories/1.json
  def update

    if @category.update_attributes(category_params)
      flash[:notice] = 'Category was successfully updated.'
    end
    respond_with(@category, location: categories_path)
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category.destroy

    respond_with(@category)
  end

  private
  def category_params
    params.require(:category).permit(:name, :position, :info_url,
                                     :translations_attributes => [:id, :locale, :name])
  end
end
