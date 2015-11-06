class Translations::CategoriesController < Admin::TranslationsController
  before_action :load_category, except: :index

  def index
    @categories = Category.all
  end

  # GET /translations/categories/1/edit
  def edit
  end

  # PUT /translations//categories/1
  def update
    if @category.update_attributes(category_params)
      flash[:notice] = 'Category was successfully updated.'
      redirect_to action: :index
    else
      render :edit
    end
  end

  private

  def load_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(translations_attributes: [:id, :locale, :name])
  end
end
