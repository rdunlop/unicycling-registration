require 'spec_helper'
require 'upload'

describe Upload do
  before (:each) do
  end

  describe "NAUCC File Upload" do
    it "returns the file as an array with named hashes" do
        address_file = fixture_path + '/Address.csv'
        address_input = Rack::Test::UploadedFile.new(address_file, "text/plain")

        up = Upload.new

        arr = up.get_file(address_input)

        arr.empty?.should == false

        arr.count.should == 103

        arr.first["Address1"].should == "3200 90th st"
        arr.first["T Youth Medium"].should == "0"
        arr.first["Registration Fee"].should == "90.00"
        arr.first["T-Shirt Fee"].should == "15.00"
        arr.first["USA Fee"].should == "20.00"
        arr.first["Dinner Fee"].should == "5.00"
        arr.first["T Youth Medium"].should == "0"
        arr.first["T Youth Large"].should == "0"
        arr.first["T Adault Small"].should == "1"
        arr.first["T Adault Medium"].should == "0"
        arr.first["T Adault Large"].should == "0"
        arr.first["T Adault X Large"].should == "0"
        arr.first["T Adault XX Large"].should == "0"
        arr.first["T Adault XX Large2"].should == "0"

        arr[3]["T Adault XX Large"].should == "1"
        arr[36]["T Adault XX Large2"].should == "1"
    end

    it "should process naucc_files into a single hash" do
        address_file = fixture_path + '/Address.csv'
        address_input = Rack::Test::UploadedFile.new(address_file, "text/plain")

        person_file = fixture_path + '/Person.csv'
        person_input = Rack::Test::UploadedFile.new(person_file, "text/plain")

        events_file = fixture_path + '/Events.csv'
        event_input = Rack::Test::UploadedFile.new(events_file, "text/plain")

        up = Upload.new

        arr = up.combine_arrays(up.get_file(address_input), up.get_file(person_input), up.get_file(event_input))

        arr.empty?.should == false

        arr.count.should == 246

        sample = arr.first
        sample["First Name"].should == "Kendra"
        sample["Address1"].should == "3200 90th st" # from Address.csv
        sample["100M"].should == "1" # from Events.csv
    end

    it "should combine arrays, but only add the payment data once" do
        address_file = fixture_path + '/Address.csv'
        address_input = Rack::Test::UploadedFile.new(address_file, "text/plain")

        person_file = fixture_path + '/Person.csv'
        person_input = Rack::Test::UploadedFile.new(person_file, "text/plain")

        events_file = fixture_path + '/Events.csv'
        event_input = Rack::Test::UploadedFile.new(events_file, "text/plain")

        up = Upload.new

        arr = up.combine_arrays(up.get_file(address_input), up.get_file(person_input), up.get_file(event_input))

        arr.empty?.should == false

        arr.count.should == 246

        # 17 is the first entry with all fees
        sample = arr[17]
        sample["First Name"].should == "Kevin"
        sample["Registration Fee"].should == "235.00"
        sample["T-Shirt Fee"].should == "30.00"
        sample["USA Fee"].should == "35.00"
        sample["Dinner Fee"].should == "65.00"
        sample["T Youth Medium"].should == "0"
        sample["T Youth Large"].should == "0"
        sample["T Adault Small"].should == "0"
        sample["T Adault Medium"].should == "1"
        sample["T Adault Large"].should == "1"
        sample["T Adault X Large"].should == "0"
        sample["T Adault XX Large"].should == "0"
        sample["T Adault XX Large2"].should == "0"

        sample = arr[18]
        sample["First Name"].should == "Stephen "
        sample["Registration Fee"].should == "0"
        sample["T-Shirt Fee"].should == "0"
        sample["USA Fee"].should == "0"
        sample["Dinner Fee"].should == "0"
        sample["T Youth Medium"].should == "0"
        sample["T Youth Large"].should == "0"
        sample["T Adault Small"].should == "0"
        sample["T Adault Medium"].should == "0"
        sample["T Adault Large"].should == "0"
        sample["T Adault X Large"].should == "0"
        sample["T Adault XX Large"].should == "0"
        sample["T Adault XX Large2"].should == "0"
    end
  end

  describe "NAUCC hash conversion" do
    before(:each) do
        @reg = {
            "Address_ID" => "10005",
            "Address1" => "233 East Wacker Drive",
            "Address2" => "Apartment 2203",
            "City" => "Chicago",
            "State" => "IL",
            "Zip" => "60601",
            "Country" => "United States of America",
            "Club" => "ChicagoUnicyclists",
            "Club Contact" => "Joe Blo",

            "Person_ID" => "10001",
            "First Name" => "Robin",
            "Middle Initial" => "A",
            "Last Name" => "Dunlop",
            "Bmonth" => "5",
            "Bday" => "20",
            "Byear" => "1982",
            "Sex" => "Male",
            'USA #' => "12345",
            "Race Age" => "30-39",
            "Registration Type" => "Rider",

            "100M" => "1",
            "400M" => "1",
            "800M" => "1",
            "10M Wheel Walk" => "1",
            "30MWheel Walk" => "1",
            "One Foot" => "1",
            "Slow Forward" => "1",
            "Slow Backward" => "1",
            "Obsticle Course" => "1",
            "High Jump" => "1",
            "Long Jump" => "1",
            "Juggling" => "1",
            "Ultimate Wheel" => "1",
            "Coasting" => "1",
            "Relay Raqce" => "1",
            "Basketball" => "1",
            "Hockey" => "1",
            "CrossCountry" => "1",
            "10K" => "1",
            "Marathon" => "1",
            "Criterium" => "1",
            "Standard Skill" => "1",
            "Individual" => "Not Participating",
            "Pairs" => "Adult Novice",
            "Pairs Partner" => "Connie Cotter",
            "Group" => "1",
            "Group Name" => "my group",
            "Traditional Club" => "1",
            "Intermediate Club" => "1",
            "All Club" => "1",
            "Traditional Club Name" => "The Tra Club",
            "Intermediate Club Name" => "The int Club",
            "All Club Name" => "The All Club",
            "Flatland" => "Not Participating",
            "Street" => "Not Participating",
            "Trials" => "Beginner",
            "UpHill" => "1",
            "Downhill" => "1",
            "Attending Dinner" => "1",
            "Adult On-Site" => "Bob Smith",
            "Telephone" => "291-291-3921",
            "Email" => "Robin@dunlopweb.com",
            "T Youth Medium" => "1",
            "T Youth Large" => "2",
            "T Adault Small" => "3",
            "T Adault Medium" => "4",
            "T Adault Large" => "5",
            "T Adault X Large" => "6",
            "T Adault XX Large" => "7",
            "T Adault XX Large2" => "8",
            "Registration Fee" => "90.00",
            "T-Shirt Fee" => "30",
            "USA Fee" => "35.00",
            "Dinner Fee" => "25.00",
        }
    end
    it "should output the correct SQL string" do
        up = Upload.new

        result = up.convert_hash_to_string(@reg)

        result.should == "insert into `reg_registration` values (1,0,'Robin','A','Dunlop',5,20,1982,'Male','233 East Wacker Drive','Apartment 2203','Chicago','IL','60601','United States of America','291-291-3921','','Robin@dunlopweb.com','','','ChicagoUnicyclists','Joe Blo','12345','','','',null,'','','','','','','','','','','','','Bob Smith','','','yes',null,'yes','yes','yes','yes','yes','yes','yes','yes',null,'yes','','unlimited','unlimited','','','','yes','yes',null,'','Adult Novice','Connie Cotter','Small Group','my group','A Tournament',null,'','','A Tournament',null,'','',null,null,null,null,null,null,null,null,null,'yes',null,'yes',null,'yes',null,'Beginner','','yes','yes','','','',null,null,null,'yes',null,null,'','','','','','',null,'','','','',null,null,'',null,'','','1','2','3','4','5','6','7','8','90.00','2','0','1','5','1','1','1','traditionalclub','intermediateclub','allclub','The Tra Club','The int Club','The All Club',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,'',2,'59.99','','59.99','','59:59.99','','59:59.99','','59.99','','59.99','','59.99','','180.00','','>6:00','','<20 cm','','<30 cm','','0000-00-00 00:00:00','0000-00-00 00:00:00');\n"
    end
  end
end
