class CategoriesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_new_category, :only => [:create]
  load_and_authorize_resource

  def load_new_category
    @category = Category.new(category_params)
  end

  def load_categories
    @categories = Category.all
  end

  # GET /categories
  # GET /categories.json
  def index
    load_categories
    @category = Category.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @categories }
    end
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
        load_categories
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

    respond_to do |format|
      format.html { redirect_to categories_url }
      format.json { head :no_content }
    end
  end

  private
  def category_params
    params.require(:category).permit(:name, :position, :info_url)
  end
end
