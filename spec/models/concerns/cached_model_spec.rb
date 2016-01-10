require "spec_helper"

class CachedModelTest
  include ActiveSupport::Callbacks
  define_callbacks :after_touch
  define_callbacks :after_save
  define_callbacks :after_destroy

  def self.model_name
    name
  end

  def changes
    {}
  end

  def self.after_touch(method_to_invoke)
    set_callback :after_touch, method_to_invoke
  end

  def touch
    run_callbacks :after_touch
  end

  def self.after_save(method_to_invoke)
    set_callback :after_save, method_to_invoke
  end

  def save
    run_callbacks :after_save
  end

  def self.after_destroy(method_to_invoke)
    set_callback :after_destroy, method_to_invoke
  end

  def destroy
    run_callbacks :after_destroy
  end

  include CachedModel
end

shared_examples_for "does update the global key" do
  it "updates the global key" do
    original_key = CachedModelTest.cache_key
    Delorean.time_travel_to(2.seconds.from_now) do
      do_action
    end
    expect(CachedModelTest.cache_key).not_to eq(original_key)
  end
end

shared_examples_for "does not update the global key" do
  it "does not update the global key" do
    original_key = CachedModelTest.cache_key
    Delorean.time_travel_to(2.seconds.from_now) do
      do_action
    end
    expect(CachedModelTest.cache_key).to eq(original_key)
  end
end

describe "CachedModel", caching: true do
  let(:model) { CachedModelTest.new }
  before { Rails.cache.clear }

  it "has a cached_key at the class level" do
    expect(CachedModelTest.cache_key).not_to be_nil
  end

  describe "touch" do
    let(:do_action) { model.touch }
    it_should_behave_like "does update the global key"
  end

  describe "when nothing is changed" do
    let(:changes) { {} }

    before { allow(model).to receive(:changes).and_return(changes) }

    let(:do_action) { model.save }
    it_should_behave_like "does not update the global key"
  end

  describe "when a field has changed" do
    let(:changes) { { attribute: "changed" } }
    before { allow(model).to receive(:changes).and_return(changes) }

    let(:do_action) { model.save }
    it_should_behave_like "does update the global key"
  end

  describe "when an ignored field has changed" do
    let(:changes) { { attribute: "changed" } }
    before { allow(model).to receive(:changes).and_return(changes) }
    before { allow(model).to receive(:ignored_for_collection_invalidation_fields).and_return([:attribute]) }

    let(:do_action) { model.save }
    it_should_behave_like "does not update the global key"
  end
end
