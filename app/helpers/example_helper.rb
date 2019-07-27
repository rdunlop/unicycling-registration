module ExampleHelper
  # Based on whether we're accessing in through the admin or public paths
  # generate a different URL
  # Either
  # freestyle_event_competition_choices_path(@event)
  # or
  # freestyle_example_competition_choices_path
  #
  def example_link(string, element)
    # rubocop:disable Rails/HelperInstanceVariable
    if @event.present?
      link_to string, [element.to_sym, @event, :competition_choices]
    else
      link_to string, [element.to_sym, :example, :competition_choices]
    end
    # rubocop:enable Rails/HelperInstanceVariable
  end

  def example_download_link(string, filename)
    # rubocop:disable Rails/HelperInstanceVariable
    if @event.present?
      link_to string, [:download_file, @event, :competition_choices, filename: filename]
    end
    # rubocop:enable Rails/HelperInstanceVariable
  end
end
