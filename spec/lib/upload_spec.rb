require 'spec_helper'
require 'upload'

describe Upload do
  before (:each) do
  end

  it "can extract csv for normal race results" do
    sample_file = fixture_path + '/sample_time_results_bib_101.txt'
    sample_input = Rack::Test::UploadedFile.new(sample_file, "text/plain")

    up = Upload.new

    data = up.extract_csv(sample_input)

    data.count.should == 1
  end

  it "can extract csv for lif race results" do
    sample_file = fixture_path + '/800m14.lif'
    sample_input = Rack::Test::UploadedFile.new(sample_file, "text/plain")

    up = Upload.new

    data = up.extract_lif(sample_input)

    data.count.should == 8
  end

  it "can convert an disqualification into data" do
    up = Upload.new

    arr = [7,'',4,'','','',"DQ",'','','','','','','','']

    hash = up.convert_to_hash(arr)
    hash[:minutes].should == 0
    hash[:seconds].should == 0
    hash[:thousands].should == 0
    hash[:disqualified].should == true
  end

  it "can convert an array of data into minutes, seconds, thousands, dq" do
    up = Upload.new

    arr = [3,'',7,'','','',32.49,'',12.142,'','','','','','']

    hash = up.convert_to_hash(arr)
    hash[:lane].should == 7
    hash[:minutes].should == 0
    hash[:seconds].should == 32
    hash[:thousands].should == 490
    hash[:disqualified].should == false
  end
  it "can convert an array of data into minutes, seconds, thousands, dq" do
    up = Upload.new

    arr = [3,'',7,'','','',"1:32.49",'',12.142,'','','','','','']

    hash = up.convert_to_hash(arr)
    hash[:lane].should == 7
    hash[:minutes].should == 1
    hash[:seconds].should == 32
    hash[:thousands].should == 490
    hash[:disqualified].should == false
  end
end
