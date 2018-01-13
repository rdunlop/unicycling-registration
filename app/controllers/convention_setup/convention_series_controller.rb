class ConventionSetup::ConventionSeriesController < ConventionSetup::BaseConventionSetupController
  before_action :load_series, only: %i[show destroy add remove]
  before_action :authorize_series, only: %i[show destroy add remove]

  # Show all series
  def index
    authorize ConventionSeries.new, :index?
    @series = ConventionSeries.all
    @new_series = ConventionSeries.new
  end

  # show members+registrants of the series
  def show; end

  # create a new series
  def create
    @new_series = ConventionSeries.new(convention_series_params)
    authorize @new_series
    if @new_series.save
      flash[:notice] = "Series created successfully"
      redirect_to convention_series_path(@new_series)
    else
      flash[:alert] = "Error creating series"
      @series = ConventionSeries.all
      render :index
    end
  end

  # delete the selected series, as long as it is not being used
  def destroy
    if @series.destroy
      flash[:notice] = "Successfully deleted Series"
    else
      flash[:alert] = "Error deleting series"
    end

    redirect_to convention_series_index_path
  end

  # Add current tenant to the provided series
  def add
    if @series.add(Apartment::Tenant.current)
      flash[:notice] = "Successfully added to #{@series}"
    else
      flash[:alert] = "Error adding to #{@series}"
    end

    redirect_to convention_series_path(@series)
  end

  # remove current tenant from the provided series
  def remove
    if @series.remove(Apartment::Tenant.current)
      flash[:notice] = "Successfully removed from #{@series}"
    else
      flash[:alert] = "Error removing from #{@series}"
    end

    redirect_to convention_series_path(@series)
  end

  private

  def authorize_series
    authorize @series
  end

  def load_series
    @series = ConventionSeries.find(params[:id])
  end

  def convention_series_params
    params.require(:convention_series).permit(:name)
  end
end
