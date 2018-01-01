require "spec_helper"

class CachedSetModelTest
  include ActiveSupport::Callbacks
  include ActiveModel::Model

  define_callbacks :after_touch
  define_callbacks :after_save
  define_callbacks :after_destroy

  attr_accessor :expense_item_id

  def self.model_name
    name
  end

  def self.cache_set_field
    :expense_item_id
  end

  def recent_changes
    changes
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

  include CachedSetModel
end

shared_examples_for "does update the global key" do
  it "updates the global key" do
    original_key = CachedSetModelTest.cache_key_for_set(key)
    travel 2.seconds do
      do_action
    end
    expect(CachedSetModelTest.cache_key_for_set(key)).not_to eq(original_key)
  end
end

shared_examples_for "does not update the global key" do
  it "does not update the global key" do
    original_key = CachedSetModelTest.cache_key_for_set(key)
    travel 2.seconds do
      do_action
    end
    expect(CachedSetModelTest.cache_key_for_set(key)).to eq(original_key)
  end
end

describe "CachedSetModel", caching: true do
  let(:model) { CachedSetModelTest.new(expense_item_id: key) }
  let(:key) { 10 }
  before { Rails.cache.clear }

  it "has a cached_key_for_set at the class level" do
    expect(CachedSetModelTest.cache_key_for_set(key)).not_to be_nil
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
end
