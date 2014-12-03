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
    respond_to do |format|
      if @category.save
        format.html { redirect_to categories_path, notice: 'Category was successfully created.' }
        format.json { render json: @category, status: :created, location: categories_path }
      else
        @categories = Category.all
        format.html { render action: "index" }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.json
  def update
    respond_to do |format|
      if @category.update_attributes(category_params)
        format.html { redirect_to categories_path, notice: 'Category was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
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
