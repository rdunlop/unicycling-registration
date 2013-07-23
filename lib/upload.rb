require 'csv'
class Upload

  def extract_csv(file)
    if file.respond_to?(:tempfile)
      upload_file = file.tempfile
    else
      upload_file = file
    end

    results = []
    File.open(upload_file, 'r:ISO-8859-1') do |f|
      f.each do |line|
        row = CSV.parse_line (line)
        results << row
      end
    end
    results
  end

  # CSV File exported from UCP
  def process_csv_upload(params)
    n=0
    if params[:dump][:file].respond_to?(:tempfile)
        upload_file = params[:dump][:file].tempfile
    else
        upload_file = params[:dump][:file]
    end

    File.open(upload_file, 'r:ISO-8859-1') do |f|
     f.each do |line|
      row = CSV.parse_line (line)
      # sample rows:
      #1,"Robin","Dunlop",1,29,"Male"
      #2,"Connie","Cotter",1,46,"Female"
      #3,"Ann","O'Brien",0,53,"Female"
      c=Registrant.new
      c.initialize_from_array(row)
      if c.save
        n=n+1
      end
     end
    end
    n
  end

###########################################
# NAUCC 2012 Exported fileset
###########################################
  def get_combined_data(address_file, person_file, events_file)
    addresses = get_file(address_file)
    persons = get_file(person_file)
    events = get_file(events_file)

    results = combine_arrays(addresses, persons, events)
    results
  end

  def process_naucc_upload(params)
    if params[:naucc][:address_file].respond_to?(:tempfile)
        address_file = params[:naucc][:address_file].tempfile
        person_file = params[:naucc][:person_file].tempfile
        events_file = params[:naucc][:events_file].tempfile
    else
        address_file = params[:naucc][:address_file]
        person_file = params[:naucc][:person_file]
        events_file = params[:naucc][:events_file]
    end
    results = get_combined_data(address_file, person_file, events_file)
    n = 0
    results.each do |reg|
        c = Registrant.new
        c.external_id = (reg["Person_ID"].to_i - 10000)
        c.first_name  = reg["First Name"]
        c.last_name   = reg["Last Name"]
        c.competitor  = reg["Registration Type"] == "Rider"
        #puts         (Time.local(2012,07,10) - Time.local(reg["Byear"].to_i, reg["Bmonth"].to_i, reg["Bday"].to_i)) / 1.year
        c.age         = ((Time.local(2012,07,10) - Time.local(reg["Byear"].to_i, reg["Bmonth"].to_i, reg["Bday"].to_i)) / 1.year).to_i
        c.gender      = reg["Sex"]
        if c.save
            n = n + 1
        else
            #puts "error: #{reg}"
        end
    end
    n
  end

  def combine_arrays(addresses, persons, events)
    results = []
    persons.each do |person|
        new_entry = person
        addresses.each do |addr|
            if addr["Address_ID"] == person["Address_ID"]
                addr.each do |key, val|
                    if key != "Address_ID"
                        new_entry[key] = val
                    end
                end
                addr["Registration Fee"] = "0"
                addr["T-Shirt Fee"] = "0"
                addr["USA Fee"] = "0"
                addr["Dinner Fee"] = "0"
                addr["Dinner Fee"] = "0"
                addr["T Youth Medium"] = "0"
                addr["T Youth Large"] = "0"
                addr["T Adault Small"] = "0"
                addr["T Adault Medium"] = "0"
                addr["T Adault Large"] = "0"
                addr["T Adault X Large"] = "0"
                addr["T Adault XX Large"] = "0"
                addr["T Adault XX Large2"] = "0"
            end
        end
        events.each do |addr|
            if addr["Person_ID"] == person["Person_ID"]
                addr.each do |key, val|
                    if key != "Person_ID"
                        new_entry[key] = val
                    end
                end
            end
        end
        results << new_entry
    end

    results
  end

  def get_file(upload_file)
      titles = nil
      results = []
      File.open(upload_file, 'r:ISO-8859-1') do |f|
        f.each do |line|
          row = CSV.parse_line (line)
          if titles.nil?
              titles = []
              row.each do |col|
                # if the column already exists, create a new column with '2' appended to it
                if titles.include?(col)
                    titles << col.to_s + "2"
                else
                    titles << col.to_s
                end
              end
          else
              new_row = Hash.new
              row.each_with_index do |col, i|
                new_row[titles[i]] = col
              end
              results << new_row
          end
        end
      end
      results
  end

#########################################################
# Convert from NAUCC Hash to UCP (UNICON XVI-format) SQL
#########################################################

  def add_int(hash, key)
    if hash.key?(key)
        "#{hash[key]},"
    else
        "0,"
    end
  end

  def add_string(hash, key)
    if hash.key?(key)
        "'#{hash[key]}',"
    else
        "'',"
    end
  end

  def add_enum(hash, key)
    if hash.key?(key)
        if hash[key] == "1"
            "'yes',"
        else
            "null,"
        end
    else
        "null,"
    end
  end

  def add_fake_string(count)
    res = ""
    count.times do |c|
        res += "'',"
    end

    res
  end
  def add_fake_enum(count)
    res = ""
    count.times do |c|
        res += "null,"
    end

    res
  end

  def add_converted_string(hash, key, replace_value)
    if hash.key?(key)
        if hash[key] == "1"
            "'#{replace_value}',"
        else
            "'',"
        end
    else
        "'',"
    end
  end

  def convert_hash_to_string(hash)
    r = "insert into `reg_registration` values ("
    r += (hash["Person_ID"].to_i - 10000).to_s + "," # convert "10001" into "1"
    r += add_int(hash, 'user_id') #fake
    r += add_string(hash, 'First Name')
    r += add_string(hash, 'Middle Initial')
    r += add_string(hash, 'Last Name')
    r += add_int(hash, 'Bmonth')
    r += add_int(hash, 'Bday')
    r += add_int(hash, 'Byear')
    r += add_string(hash, 'Sex')
    r += add_string(hash, 'Address1')
    r += add_string(hash, 'Address2')
    r += add_string(hash, 'City')
    r += add_string(hash, 'State')
    r += add_string(hash, 'Zip')
    r += add_string(hash, 'Country')
    r += add_string(hash, 'Telephone')
    r += add_string(hash, 'Mobile') #fake
    r += add_string(hash, 'Email')
    r += add_string(hash, 'Language') #fake
    r += add_string(hash, 'Language2') #fake
    r += add_string(hash, 'Club')
    r += add_string(hash, 'Club Contact')
    r += add_string(hash, 'USA #')
    r += add_string(hash, 'iufid') #fake
    r += add_fake_string(2)  #emergency
    r += add_fake_enum(1)    #emergency
    r += add_fake_string(4) #emergency
    r += add_fake_string(8) #parent
    r += add_string(hash, 'Adult On-Site') #parentadult
    r += add_fake_string(2) # racing, wheelextra
    r += add_enum(hash, '100M')
    r += add_enum(hash, '100Mopen') #fake
    r += add_enum(hash, '400M')
    r += add_enum(hash, '800M')
    r += add_enum(hash, 'One Foot')
    r += add_enum(hash, '10M Wheel Walk')
    r += add_enum(hash, '30MWheel Walk')
    r += add_enum(hash, 'Obsticle Course')
    r += add_enum(hash, 'Slow Forward')
    r += add_enum(hash, 'Slow Backward')
    r += add_enum(hash, 'Stillstand') #fake
    r += add_enum(hash, 'Relay Raqce')
    r += add_fake_string(1) #relay team name
    r += add_converted_string(hash, '10K', 'unlimited')
    r += add_converted_string(hash, 'Marathon', 'unlimited')
    r += add_fake_string(3) #100k
    r += add_enum(hash, 'Standard Skill')
    r += add_enum(hash, 'Coasting')
    r += add_enum(hash, 'Gliding') #fake
    r += add_art(hash, 'Individual')
    r += add_art(hash, 'Pairs')
    r += add_string(hash, 'Pairs Partner')
    r += add_converted_string(hash, 'Group', 'Small Group') #XXX
    r += add_string(hash, 'Group Name')

    r += add_converted_string(hash, 'Basketball', 'A Tournament')
    r += add_enum(hash, 'Basketball Mixed') #fake
    r += add_string(hash, 'BB Team Name') #fake
    r += add_string(hash, 'BB Team Capt') #fake
    r += add_converted_string(hash, 'Hockey', 'A Tournament')
    r += add_enum(hash, 'Hockey Mixed') #fake
    r += add_string(hash, 'Hockey Team Name') #fake
    r += add_string(hash, 'Hockey Team Capt') #fake

    r += add_fake_enum(5) #fun
    r += add_fake_enum(4) #shuttle

    r += add_enum(hash, 'UpHill')
    r += add_enum(hash, 'UpHill Expert') #fake
    r += add_enum(hash, 'Downhill')
    r += add_enum(hash, 'Downhill Expert') #fake
    r += add_enum(hash, 'CrossCountry')
    r += add_enum(hash, 'Muni Obstacles') #fake
    r += add_art(hash, 'Trials')
    r += add_art(hash, 'Speed Trials') #fake
    r += add_enum(hash, 'High Jump')
    r += add_enum(hash, 'Long Jump')

    r += add_art(hash, 'Street')
    r += add_art(hash, 'Flatland')

    r += add_string(hash, 'T-Shirt') # XXX

    r += add_fake_enum(3) # extra shirt, ceremonies, gala

    r += add_enum(hash, 'Attending Dinner') # XXX

    r += add_fake_enum(2)
    r += add_fake_string(5)
    r += add_fake_string(1)
    r += add_fake_enum(1)
   
    r += add_string(hash, 'Workshop') # XXX
    r += add_fake_string(3)

    r += add_fake_enum(2)
    r += add_fake_string(1)
    r += add_fake_enum(1)
    r += add_fake_string(2)

#- Reusing some UNICON fields for nationals data:
# - # of:
#  - T-Shirt Youth Medium - thursday19registration
#  - T-Shirt Youth Large - thursday19buildtrials
#  - T-Shirt Adult Small - thursday19othervolunteers
#  - T-Shirt Adult Medium - friday20registration
#  - T-Shirt Adult Large - friday20othervolunteers
#  - T-Shirt Adult X Large - saturday2110kroadguard
#  - T-Shirt Adult XX Large - saturday2110kpaperworkstart
#  - T-Shirt Adult XXX Large - saturday21trialsofficial
# - Registration Fee - Total cost - saturday21pairsfreestylepaperwork
# - T-Shirt Fee - Total # T-Shirts - saturday21pairsfreestylejudge
# - USA Fee Individual - saturday21othervolunteers
# - USA Fee Family - sunday22munitrailguard
# - Dinner Fee - # of dinners - sunday22munipaperwork



    r += add_string(hash, 'T Youth Medium') # thursday19registration
    r += add_string(hash, 'T Youth Large') # thursday19buildtrials
    r += add_string(hash, 'T Adault Small') # thursday19othervolunteers
    r += add_string(hash, 'T Adault Medium') # friday20registration
    r += add_string(hash, 'T Adault Large') # friday20othervolunteers
    r += add_string(hash, 'T Adault X Large') # saturday2110kroadguard
    r += add_string(hash, 'T Adault XX Large') # saturday2110kpaperworkstart
    r += add_string(hash, 'T Adault XX Large2') # saturday21trialsofficial
    r += add_string(hash, 'Registration Fee') # saturday21pairsfreestylepaperwork

    cost = hash['T-Shirt Fee'].to_i
    r += "'#{cost/15}'," # saturday21pairsfreestylejudge

    cost = hash['USA Fee']
    if (cost == "20.00")
        r += "'1'," # saturday21othervolunteers
    else
        r += "'0'," # same
    end
    
    if (cost == "35.00")
        r += "'1'," # sunday22munitrailguard
    else
        r += "'0'," # same
    end

    cost = hash['Dinner Fee'].to_i
    r += "'#{cost/5}'," # sunday22munipaperwork

# EVENT Field that don't have UNICON equivalents
    r += add_string(hash, 'Juggling') # sunday22downhillglidingguard
    r += add_string(hash, 'Ultimate Wheel') # sunday22downhillglidingpaperwork
    r += add_string(hash, 'Criterium') # sunday22othervolunteers
    r += add_converted_string(hash, 'Traditional Club','traditionalclub') # monday23hockeyreferee
    r += add_converted_string(hash, 'Intermediate Club', 'intermediateclub') # monday23bballreferee
    r += add_converted_string(hash, 'All Club', 'allclub') # monday23bein
    r += add_string(hash, 'Traditional Club Name') # monday23groupfreestylejudge
    r += add_string(hash, 'Intermediate Club Name') # monday23othervolunteers
    r += add_string(hash, 'All Club Name') # tuesday24tracklaneposition

    r += add_fake_enum(48)
    
    r += add_fake_string(1) #mywish

    if (hash["Registration Type"] == "Rider")
        r += "2,"
    else
        r += "1,"
    end

    r += "'59.99','','59.99','','59:59.99','','59:59.99','','59.99','','59.99','','59.99','','180.00','','>6:00','','<20 cm','','<30 cm','','0000-00-00 00:00:00','0000-00-00 00:00:00'"

    r += ");\n"
    r
  end

  def add_art(hash, key)
    if hash.key?(key)
        if hash[key] == "Not Participating"
            "'',"
        else
            "'#{hash[key]}',"
        end
    else
        "'',"
    end
  end

  ##############################################
  # THE MAIN FUNCTION Entrypoint into this code 
  ##############################################
  def convert(params)
    if params[:convert][:address_file].respond_to?(:tempfile)
        address_file = params[:convert][:address_file].tempfile
        person_file = params[:convert][:person_file].tempfile
        events_file = params[:convert][:events_file].tempfile
    else
        address_file = params[:convert][:address_file]
        person_file = params[:convert][:person_file]
        events_file = params[:convert][:events_file]
    end
    results = get_combined_data(address_file, person_file, events_file)

    result = ""
    results.each do |row|
        result += convert_hash_to_string(row)
    end
    result
  end
end
