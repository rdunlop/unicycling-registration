shared_context 'can display correct state, country, club' do |options|
  describe "when EventConfiguration wants to display the state" do
    before do
      EventConfiguration.singleton.update(representation_type: "state")
    end

    it "displays the associated state" do
      expect(subject.representation).to eq(options[:state])
    end
  end

  describe "when EventConfiguration wants to display the country" do
    before do
      EventConfiguration.singleton.update(representation_type: "country")
    end

    it "displays the associated representing-country" do
      expect(subject.representation).to eq(options[:country])
    end
  end

  describe "when EventConfiguration wants to display the club" do
    before do
      EventConfiguration.singleton.update(representation_type: "club")
    end

    it "displays the associated club" do
      expect(subject.representation).to eq(options[:club])
    end
  end
end
