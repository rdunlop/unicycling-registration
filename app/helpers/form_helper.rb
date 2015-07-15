# app/helpers/form_helper
module FormHelper
  def setup_registrant_group(registrant_group)
    registrant_group ||= RegistrantGroup.new
    (Registrant.active.all - registrant_group.registrant_group_members.map {|rgm| rgm.registrant }).each do |registrant|
      registrant_group.registrant_group_members.build(registrant_id: registrant.id)
    end
    # registrant_group.registrant_group_members.sort_by! {|x| x.registrant.bib_number }
    # user/tmp/clean-controllers.md.html
    registrant_group
  end

  def registrant_bib_number_select_box(form, competition)
    form.select :bib_number, eligible_registrants(competition).map{ |reg| [reg.with_id_to_s, reg.bib_number] }, {include_blank: true}, {autofocus: true, class: 'chosen-select js--autoFocus'}
  end

  def eligible_registrants(competition)
    if @config.usa_membership_config?
      Registrant.active.competitor
    else
      competition.registrants.reorder(:bib_number)
    end
  end

  def registrant_id_select_box(form, competition)
    form.select :registrant_id, eligible_registrants(competition).map{ |reg| [reg.with_id_to_s, reg.id] }, {include_blank: true}, {autofocus: true, class: 'chosen-select js--autoFocus'}
  end

  # The form element which is used to enter data
  def competitor_select_box(form, competition, options = {})
    options.merge!(autofocus: true, class: "chosen-select js--autoFocus #{options[:class]}")
    disabled_ids = options[:disabled_ids]
    form.select :competitor_id, competition.competitors.active.ordered.map { |comp| ["##{comp.bib_number}-#{comp}", comp.id] }, {include_blank: true, disabled: disabled_ids}, options
  end

  # The form element which is used to create a new competitor, if one shows up last minute for a competition
  def non_signed_up_registrant_select_box(form, competition)
    registrants = Registrant.active.competitor - competition.competitors.flat_map(&:registrants)
    form.select(:registrant_id, registrants.map{ |reg| [reg.with_id_to_s, reg.id]}, {include_blank: true}, {class: 'chosen-select'})
  end

  def no_form_competitor_select_box(competition)
    select_tag :competitor_id, options_from_collection_for_select(competition.competitors.active, "id", "to_s_with_id"), include_blank: true, class: "chosen-select js--autoFocus"
  end

  def all_registrant_competitors(form)
    form.select :registrant_id,  Registrant.select_box_options, {include_blank: true}, {autofocus: true, class: 'chosen-select js--autoFocus'}
  end

  def wizard_progress_bar(allow_navigation = false)
    content_tag(:ul, class: "button-group") do
      wizard_steps.collect do |every_step|
        class_str = "secondary"
        li_class_str = "button secondary disabled"
        if every_step == step
          class_str = nil
          li_class_str = "button"
        end
        if past_step?(every_step)
          class_str = "success"
          li_class_str = nil
        else
          #li_class_str = "button secondary disabled"
        end
        concat(
          content_tag(:li, class: li_class_str) do
            link_to_if past_step?(every_step) || allow_navigation, I18n.t("wizard.#{every_step}"), wizard_path(every_step), class: "button #{class_str}"
          end
        )
      end
    end
  end
end
