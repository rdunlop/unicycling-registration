class EmailFilters::Competitions
  def initialize(arguments = nil)
    @arguments = arguments
  end

  def self.filter
    "competition"
  end

  def self.description
    "Users who are assigned to a competition"
  end

  # Possible options :boolean, :select, :multi_select
  def self.input_type
    :multi_select
  end

  # For use in the input builder
  # Each of these objects should have a policy which
  # responds to `:contact_registrants?`
  def self.possible_arguments
    Competition.event_order.all
  end

  # For use in the input builder
  # Should return an array [descriptive_string, element_id]
  def self.show_argument(element)
    [element, element.id]
  end

  def detailed_description
    "Emails of users/registrants associated with #{competitions.map(&:to_s).join(' ')}"
  end

  def filtered_user_emails
    competitions.map(&:registrants).flatten.map(&:user).map(&:email).compact.uniq
  end

  def filtered_registrant_emails
    competitions.map(&:registrants).flatten.map(&:contact_detail).compact.map(&:email).compact.uniq
  end

  # object whose policy must respond to `:contact_registrants?`
  def authorization_object
    competitions
  end

  private

  def competitions
    return @competitions if @competitions

    @competitions = []
    if @arguments.present?
      @arguments.each do |cid|
        @competitions << Competition.find(cid) if cid.present?
      end
    end

    @competitions
  end
end
