class ConventionSetup::EventCategoryGroupingEntriesController < ConventionSetup::BaseConventionSetupController
  include SortableObject

  before_action :authorize_setup
  before_action :set_ecge_breadcrumb

  # GET /event_category_grouping_entries
  def index
    @event_category_grouping_entry = EventCategoryGroupingEntry.new
    @event_category_groupings = EventCategoryGrouping.all
    @event_categories = EventCategory.all
  end

  # POST /event_category_grouping_entries
  def create
    @event_category_grouping_entry = EventCategoryGroupingEntry.new(event_category_grouping_entry_params)
    if @event_category_grouping_entry.save
      redirect_to convention_setup_event_category_grouping_entries_path, notice: 'Category Grouping Entry was successfully created.'
    else
      @event_category_groupings = EventCategoryGrouping.all
      @event_categories = EventCategory.all
      render action: "index"
    end
  end

  # DELETE /event_category_grouping_entries/1
  def destroy
    @event_category_grouping_entry = EventCategoryGroupingEntry.find(params[:id])
    @event_category_grouping_entry.destroy
    flash[:notice] = "Category Grouping Entry deleted"

    redirect_to convention_setup_event_category_grouping_entries_path
  end

  private

  def set_ecge_breadcrumb
    add_breadcrumb "Event Category Groupings", convention_setup_event_category_grouping_entries_path
  end

  def authorize_setup
    authorize @config, :setup_convention?
  end

  def event_category_grouping_entry_params
    params.require(:event_category_grouping_entry).permit(:event_category_grouping_id, :event_category_id)
  end
end
