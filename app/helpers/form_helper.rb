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
end
