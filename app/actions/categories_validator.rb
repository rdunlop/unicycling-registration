# Validates whether a registrants combination of event_categories
# is valid, based on the EventCategoryGroup settings, which
# state that only certain combinations of event_category combinations
# are allowed
class CategoriesValidator
  attr_accessor :registrant

  def initialize(registrant)
    @registrant = registrant
  end

  def validate
    return if EventCategoryGrouping.count.zero?

    # EventCategory through Registrant#registrant_event_sign_up

    # THIS CODE mirrors what's in entries_matching_controller.js
    chosen_event_categories = registrant.registrant_event_sign_ups.select(&:signed_up?).map(&:event_category)

    # Check Each category
    return if validate_categories(chosen_event_categories)

    registrant.errors.add(:base, "This combination of Event Categories is not permitted #{chosen_event_categories.map(&:name)}")
  end

  # Returns true if valid, false otherwise
  def validate_categories(chosen_event_categories)
    # Check Each category
    chosen_event_categories.each do |target|
      acceptable_element_value_groups = EventCategoryGroupingEntry.where(event_category: target).map(&:event_category_grouping)

      next if acceptable_element_value_groups.none? # current selected value isn't in a grouping

      # against each other category
      chosen_event_categories.each do |entry|
        next if target == entry

        # Filter for any group which includes the current entry
        new_groups = acceptable_element_value_groups.select do |group|
          group.event_categories.include?(entry)
        end

        # Save this new list of groups for the next time through the inner loop
        acceptable_element_value_groups = new_groups if new_groups.any?

        acceptable_element_values = acceptable_element_value_groups.map(&:event_categories).flatten
        next if acceptable_element_values.include?(entry)

        # the currently selected value is in this group

        entry_option_values = entry.event.event_categories

        # Does this element have a value which is in the target group?

        should_select = entry_option_values.select { |option_value| acceptable_element_values.include?(option_value) }

        next if should_select.count.zero?

        return false
      end
    end

    true
  end
end
