# app/helpers/form_helper
module FormHelper
  def setup_registrant_group(registrant_group)
    registrant_group ||= RegistrantGroup.new
    (Registrant.all - registrant_group.registrant_group_members.map {|rgm| rgm.registrant }).each do |registrant|
      rg = registrant_group.registrant_group_members.build(:registrant_id => registrant.id)
      #puts "RG: #{rg.registrant}"
    end
    #registrant_group.registrant_group_members.sort_by! {|x| x.registrant.bib_number }
    #user/tmp/clean-controllers.md.html
    registrant_group
  end

  def registrant_bib_number_select_box(form, competition)
    form.select :bib_number, eligible_registrants(competition), {:include_blank => true}, {:autofocus => true, class: 'chosen-select js--autoFocus' }
  end

  def eligible_registrants(competition)
    if @config.usa?
      Registrant.select_box_options_to_bib_number
    else
      @competition.registrants.reorder(:bib_number).map{ |reg| [reg.with_id_to_s, reg.bib_number] }
    end
  end
end
