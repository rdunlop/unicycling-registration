class EmailFilters::Competitions
  attr_reader :arguments

  def initialize(arguments = nil)
    @arguments = arguments
  end

  def self.config
    EmailFilters::SelectType.new(
      filter: "competition",
      description: "Users who are assigned to a competition",
      possible_arguments: Competition.event_order.all,
      input_type: :multi_select
    )
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

  def valid?
    competitions.any?
  end

  private

  def competitions
    return @competitions if @competitions

    @competitions = []
    if arguments.present?
      arguments.each do |cid|
        @competitions << Competition.find(cid) if cid.present?
      end
    end

    @competitions
  end
end
