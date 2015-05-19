desc "This task creates a whole set of fake event/registrations/competitions/sign-ups"

def create_category(name)
  cat = Category.find_by(name: name)
  cat ||= FactoryGirl.create(:category, name: name)
end

def create_event(category, name, event_categories = [])
  event = Event.find_by(name: name)
  event ||= FactoryGirl.create(:event, category: category, name: name)
  event_categories.each_with_index do |ecat, index|
    if index == 0
      # replace the 'All' event_category
      ecat_el = event.event_categories.find_by(name: "All")
      unless ecat
        ecat_el.name = ecat
        ecat_el.save
      end
    end
    ecat_el = event.event_categories.find_by(name: ecat)
    ecat_el ||= FactoryGirl.create(:event_category, event: event, name: ecat, position: index + 2)
  end
  event
end

def create_registrant(first_name, last_name, email_name)
  user = User.find_by(email: "#{email_name}@dunlopweb.com")
  user ||= FactoryGirl.create(:user, email: "#{email_name}@dunlopweb.com")
  reg = Registrant.find_by(first_name: first_name, last_name: last_name)
  birthday = Date.today - rand(19..99).years
  reg ||= FactoryGirl.create(:competitor, first_name: first_name, last_name: last_name, user: user, birthday: birthday)
end

def sign_up_for_event(reg, event, event_category = nil)
  if reg.registrant_event_sign_ups.find_by(event: event)
    return
  end
  ecat_name = event_category || "All"
  ecat = event.event_categories.find_by(name: ecat_name)
  resu = RegistrantEventSignUp.find_by(registrant: reg, event: event, event_category: ecat)
  resu ||= FactoryGirl.create(:registrant_event_sign_up, registrant: reg, event: event, event_category: ecat, signed_up: true)
end

def sign_up_for_random_event(reg, event, event_categories)
  sign_up_for_event(reg, event, event_categories[rand(event_categories.length)])
end

def create_competition(event, competition_name, event_cat_names, source_competition = nil)
  comp = Competition.find_by(name: competition_name)
  comp ||= FactoryGirl.create(:competition, event: event, name: competition_name, scoring_class: "Shortest Time", start_data_type: "Track E-Timer", end_data_type: "Track E-Timer")

  event_cat_names.each do |ecat_name|
    ecat = event.event_categories.find_by(name: ecat_name)
    source = CompetitionSource.find_by(target_competition: comp, event_category: ecat)
    source ||= FactoryGirl.create(:competition_source, target_competition: comp, event_category: ecat)
  end

  [source_competition].each do |source|
    source = CompetitionSource.find_by(target_competition: comp, competition: source)
    source ||= FactoryGirl.create(:competition_source, target_competition: comp, competition: source)
  end
end

task :create_fake_data => :environment do
  @track = create_category("Track")
  @t100m = create_event(@track, "100m")
  @t400m = create_event(@track, "400m")
  @t800m = create_event(@track, "800m")

  @muni =  create_category("Muni")
  @uphill_events = ["Beginner", "Advanced", "Expert"]
  @uphill = create_event(@muni, "Uphill", @uphill_events)

  @collective = create_category("Collective Sports")
  @hockey_events = ["A", "B"]
  @hockey = create_event(@collective, "Hockey", @hockey_events)

  @distance =  create_category("Distance")
  @marathon = create_event(@distance, "Marathon")
  @t10k_events = ["Standard", "Unlimited"]
  @t10k = create_event(@distance, "10k", @t10k_events)

  @freestyle = create_category("Freestyle")
  @individual_events = ["Age Group", "Jr. Expert", "Expert"]
  @individual = create_event(@freestyle, "Individual", @individual_events)

  @t100_comp = create_competition(@t100m, "100m", ["All"])
  @t100_expert_comp = create_competition(@t100m, "100m Expert", [], @t100_comp)

  @regs = []
  100.times do |i|
    puts "creating #{i}"
    reg  = create_registrant("john #{i}", "smith #{i}", "john#{i}")

    sign_up_for_event(reg, @t100m)

    sign_up_for_event(reg, @t400m)

    sign_up_for_event(reg, @t800m)

    sign_up_for_random_event(reg, @uphill, @uphill_events)
    sign_up_for_random_event(reg, @hockey, @hockey_events)
    sign_up_for_random_event(reg, @t10k, @t10k_events)
    sign_up_for_random_event(reg, @individual, @individual_events)

    @regs << reg
  end
end
