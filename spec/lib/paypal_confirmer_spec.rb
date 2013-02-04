require 'spec_helper'

describe PaypalConfirmer do

  it "completed message is marked as complete" do
    params = {
      "payment_status" => "Completed"
    }
    confirmer = PaypalConfirmer.new(params, {})
    confirmer.completed?.should == true
  end

  it "is sent to the correct paypalaccount" do
    ENV['PAYPAL_ACCOUNT'] = "robin+merchant@dunlopweb.com"
    params = {
      "receiver_email" => ENV['PAYPAL_ACCOUNT']
    }
    confirmer = PaypalConfirmer.new(params, {})
    confirmer.correct_paypal_account?.should == true
  end

  it "is sent the correct paypal account even when the account was specified with upper-case characters" do
    params = {
      "receiver_email" => "robin+merchant@dunlopweb.com"
    }
    confirmer = PaypalConfirmer.new(params, {})
    confirmer.correct_paypal_account?.should == true
  end

  it "has a transaction_id" do
    params = {
      "txn_id" => "1234567890"
    }
    confirmer = PaypalConfirmer.new(params, {})
    confirmer.transaction_id.should == "1234567890"
  end

  it "has a payment_amount" do
    params = {
      "payment_gross" => "21.93"
    }
    confirmer = PaypalConfirmer.new(params, {})
    confirmer.payment_amount.should == "21.93"
  end

  it "has a order_number" do
    params = {
      "invoice" => "10"
    }
    confirmer = PaypalConfirmer.new(params, {})
    confirmer.order_number.should == "10"
  end
  it "has the correct payment date" do
    params = {
      "payment_date" => "17:11:42 Jul 15, 2008 PDT"
    }
    confirmer = PaypalConfirmer.new(params, {})
    confirmer.payment_date.should == "17:11:42 Jul 15, 2008 PDT"
  end
end
