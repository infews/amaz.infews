require File.dirname(__FILE__) + '/../spec_helper'

describe CartItemPresenter do

  before :all do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/cart_create_2_items.xml'))
    @cart_item = CartItemPresenter.new(aws_response.cart_items.first)
  end

  it 'should return the title properly from a cart response' do
    @cart_item.title.should == 'Against the Day'
  end

  it 'should return the item total from a cart response' do
    @cart_item.item_total.should == {:amount => 2448, :formatted => '$24.48'}
  end
  
end