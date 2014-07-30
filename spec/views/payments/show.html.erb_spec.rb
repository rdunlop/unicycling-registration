require 'spec_helper'

describe "payments/show" do
  let(:user) { FactoryGirl.create :user }
  before(:each) do
    @config = FactoryGirl.create(:event_configuration)
    @payment = FactoryGirl.create(:payment)
    @payment_detail = FactoryGirl.create(:payment_detail, :payment => @payment)
    @payment.reload

    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
    controller.stub(:current_user) { user }
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/#{@payment_detail.registrant}/)
  end
  it "renders a form for the paypal integration" do
    render

    assert_select "form", :action => @payment.paypal_post_url, :method => "post" do
      assert_select "input[type=hidden][name=business][value=" + ENV["PAYPAL_ACCOUNT"] +"]"
      assert_select "input[type=hidden][name=cancel_return][value=" + user_payments_url(user) + "]"
      assert_select "input[type=hidden][name=cmd][value='_cart']"
      assert_select "input[type=hidden][name=currency_code][value='USD']"
      assert_select "input[type=hidden][name=invoice][value=" + @payment.id.to_s + "]"
      assert_select "input[type=hidden][name=no_shipping][value=1]"
      assert_select "input[type=hidden][name=notify_url][value=" + notification_payments_url + "]"
      assert_select "input[type=hidden][name=return][value=" + success_payments_url + "]"
      assert_select "input[type=hidden][name=upload][value=1]"

      assert_select "input[type=submit]"
    end
  end
  it "renders the sub-entries for associated payment_details" do
    render

    assert_select "form", :action => @payment.paypal_post_url, :method => "post" do
      assert_select "input[type=hidden][name=amount_1][value=" + @payment_detail.amount.to_s + "]"
      assert_select "input[type=hidden][name=item_name_1][value=" + @payment_detail.expense_item.to_s + "]"
      assert_select "input[type=hidden][name=quantity_1][value=1]"
    end
  end
end
