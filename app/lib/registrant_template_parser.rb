class RegistrantTemplateParser
  ALLOWED_TEMPLATES = [
    ["ID", proc { |registrant| registrant.bib_number.to_s }],
    ["FirstName", proc { |registrant| registrant.first_name }],
    ["LastName", proc { |registrant| registrant.last_name }],
    ["Events", proc { |registrant| RegistrantTemplateParser.events(registrant) }],
    ["ConventionName", proc { |_| EventConfiguration.singleton.short_name }]
  ].freeze

  attr_reader :registrant, :template

  def initialize(registrant, template)
    @registrant = registrant
    @template = template
  end

  def self.template_names
    ALLOWED_TEMPLATES.map(&:first)
  end

  def valid?
    found_templates.all? { |template| self.class.template_names.include?(template) }
  end

  def found_templates
    matches = template.scan(/{{(\S+)}}/)
    matches.flatten
  end

  def result
    output = template.dup
    ALLOWED_TEMPLATES.each do |template, template_output|
      output.gsub!("{{#{template}}}", template_output.call(registrant))
    end

    output
  end

  # build a string of the events for a registrant
  # this is very similar to app/views/registrants_registrant_events.html.haml
  #
  # NOTE: This does NOT handle the case where EventConfiguration.display_confirmed_events is enabled
  def self.events(registrant)
    output = ""
    Category.includes(:events, :translations).each do |cat|
      next unless registrant.has_event_in_category?(cat)
      output += "#{cat}\n"
      output += "===================\n"

      cat.events.each do |event|
        next unless registrant.has_event?(event)
        details = registrant.describe_event_hash(event)
        output += (details[:description]).to_s
        output += " - #{details[:category]}" if details[:category].present?
        output += " #{details[:additional]}"
        output += "\n"
      end
      output += "\n\n"
    end

    output
  end
end
