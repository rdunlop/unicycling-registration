require 'spec_helper'

describe Importers::BaseImporter do
  let(:sample_input) { nil }
  let(:importer) { described_class.new(sample_input, nil, nil) }

  context "when a file is not specified" do
    it "returns an error message" do
      result = nil
      expect do
        result = importer.process
      end.not_to change(ImportResult, :count)

      expect(result).to be_falsey
      expect(importer.errors).to eq("File not found")
    end
  end
end
