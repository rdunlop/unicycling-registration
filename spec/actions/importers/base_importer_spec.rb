require 'spec_helper'

describe Importers::BaseImporter do
  context "processing a file" do
    let(:sample_input) { "thing" }
    let(:importer) { described_class.new(sample_input, processor, record_creator) }
    let(:processor) do
      dbl = double(
        extract_file: ["1", "2"]
      )
      allow(dbl).to receive(:process_row).and_return(true, nil)
      dbl
    end

    let(:record_creator) do
      double(
        save: true
      )
    end

    it "counts skipped lines" do
      importer.process
      expect(importer.num_rows_processed).to eq(1)
    end

    it "counts successful lines" do
      importer.process
      expect(importer.num_rows_skipped).to eq(1)
    end
  end

  context "when a file is not specified" do
    let(:importer) { described_class.new(nil, nil, nil) }

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
