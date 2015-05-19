# app/helpers/form_helper
module FormHelper
  def setup_registrant_group(registrant_group)
    registrant_group ||= RegistrantGroup.new
    (Registrant.all - registrant_group.registrant_group_members.map {|rgm| rgm.registrant }).each do |registrant|
      rg = registrant_group.registrant_group_members.build(:registrant_id => registrant.id)
      # puts "RG: #{rg.registrant}"
    end
    # registrant_group.registrant_group_members.sort_by! {|x| x.registrant.bib_number }
    # user/tmp/clean-controllers.md.html
    registrant_group
  end

  def registrant_bib_number_select_box(form, competition)
    form.select :bib_number, eligible_registrants(competition).map{ |reg| [reg.with_id_to_s, reg.bib_number] }, {:include_blank => true}, {:autofocus => true, class: 'chosen-select js--autoFocus' }
  end

  def eligible_registrants(competition)
    if @config.usa_membership_config?
      Registrant.active.competitor
    else
      competition.registrants.reorder(:bib_number)
    end
  end

  def registrant_id_select_box(form, competition)
    form.select :registrant_id, eligible_registrants(competition).map{ |reg| [reg.with_id_to_s, reg.id] }, {:include_blank => true}, {:autofocus => true, class: 'chosen-select js--autoFocus' }
  end

  def competitor_select_box(form, competition)
    form.select :competitor_id, competition.competitors.active.map { |comp| ["##{comp.bib_number}-#{comp}", comp.id] }, {:include_blank => true}, autofocus: true, class: 'chosen-select js--autoFocus'
  end

  def no_form_competitor_select_box(competition)
    select_tag :competitor_id, options_from_collection_for_select(competition.competitors.active, "id", "to_s_with_id"), include_blank: true, class: "chosen-select js--autoFocus"
  end

  def all_registrant_competitors(form)
    form.select :registrant_id,  Registrant.select_box_options, {:include_blank => true}, autofocus: true, class: 'chosen-select js--autoFocus'
  end

  def wizard_progress_bar(allow_navigation = false)
    content_tag(:div, class: "wizard_progress") do
      content_tag(:ul) do
        wizard_steps.collect do |every_step|
          class_str = "unfinished"
          class_str = "current"  if every_step == step
          class_str = "finished" if past_step?(every_step)
          concat(
            content_tag(:li, class: class_str) do
              link_to_if past_step?(every_step) || allow_navigation, I18n.t("wizard.#{every_step}"), wizard_path(every_step)
            end
          )
        end
      end
    end
  end
end
