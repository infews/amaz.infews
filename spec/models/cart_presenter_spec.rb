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
  
  it 'should return another array of cart items' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/cart_add_cart_B.xml'))
    @cart = CartPresenter.new(aws_response)
    @cart.items.length.should == 3
  end
  
  it 'should provide exercisable CartItemPresenters' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/cart_add_cart_B.xml'))
    @cart = CartPresenter.new(aws_response)

    @cart.items[0].title.should == 'The Wind-Up Bird Chronicle: A Novel'
    @cart.items[1].asin.should == '0143112562'
    @cart.items[2].cart_item_id.should == 'U2J1V0QO630ZEK'
  end

  it 'should report errors back from amazon.com' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/cart_get_cart_bad_cart.xml'))
    @cart = CartPresenter.new(aws_response)
    
    @cart.errors.should_not be_nil    
    @cart.errors.should == {:code => 'AWS.ECommerceService.CartInfoMismatch',
                            :message => 'Your request contains an invalid AssociateTag, CartId and HMAC combination. Please verify the AssociateTag, CartId, HMAC and retry. Remember that all Cart operations must pass in the CartId and HMAC that were returned to you during the CartCreate operation.'}
  end
  
  it 'should report if a cart is valid' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/cart_add_cart_B.xml'))
    @cart = CartPresenter.new(aws_response)

    @cart.should be_valid
  end
  
  it 'should report if a cart is invalid' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/cart_get_cart_bad_cart.xml'))
    @cart = CartPresenter.new(aws_response)

    @cart.should_not be_valid    
  end
  
end