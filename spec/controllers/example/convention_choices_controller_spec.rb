require 'spec_helper'

describe Example::ConventionChoicesController do
  actions = %i[
    index
    standard_skill
  ]

  actions.each do |action|
    it "renders successfully" do
      get action
      expect(response).to be_success
    end
  end
end
