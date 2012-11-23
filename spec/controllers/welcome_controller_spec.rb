require 'spec_helper'

describe WelcomeController do

  describe "GET 'help'" do
    it "returns http success" do
      get 'help'
      response.should be_success
    end
  end
end
