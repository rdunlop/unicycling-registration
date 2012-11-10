require "spec_helper"

describe EventConfigurationsController do
  describe "routing" do

    it "routes to #index" do
      get("/event_configurations").should route_to("event_configurations#index")
    end

    it "routes to #new" do
      get("/event_configurations/new").should route_to("event_configurations#new")
    end

    it "routes to #show" do
      get("/event_configurations/1").should route_to("event_configurations#show", :id => "1")
    end

    it "routes to #edit" do
      get("/event_configurations/1/edit").should route_to("event_configurations#edit", :id => "1")
    end

    it "routes to #create" do
      post("/event_configurations").should route_to("event_configurations#create")
    end

    it "routes to #update" do
      put("/event_configurations/1").should route_to("event_configurations#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/event_configurations/1").should route_to("event_configurations#destroy", :id => "1")
    end

  end
end
