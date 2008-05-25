require File.dirname(__FILE__) + '/../spec_helper'

describe CartPresenter do
  before :all do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/cart_create_2_items.xml'))
    @cart = CartPresenter.new(aws_response)
  end

  it 'should return the CartId from the response' do    
    @cart.cart_id.should == '104-9487830-8806330'
  end

  it 'should return the HMAC from the response' do
    @cart.hmac.should == 'Ze+9VNGLN3MRlgl2go/xH8aoiMY='
  end
  
  it 'should return the URL-encoded HMAC from the response' do
    @cart.url_encoded_hmac.should == 'Ze%2B9VNGLN3MRlgl2go%2FxH8aoiMY%3D'
  end
  
  it 'should return the PurchaseURL from the response' do
    @cart.purchase_url.should == 'https://www.amazon.com/gp/cart/aws-merge.html?cart-id=104-9487830-8806330%26associate-id=infews-20%26hmac=Ze%2B9VNGLN3MRlgl2go/xH8aoiMY=%26SubscriptionId=0525E2PQ81DD7ZTWTK82%26MergeCart=False'
  end
  
  it 'should return a hash representing the subtotal of all items in the cart' do
    @cart.subtotal.should == {:amount => 3547, :formatted => '$35.47'}
  end
  
  it 'should return an array of cart items' do
    @cart.items.length.should == 2
  end
end