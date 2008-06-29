require 'rubygems'
require File.dirname(__FILE__) + '/../spec_helper'

require 'lib/amazon_aws'

describe AmazonAWS::Response do
  
  it 'should have a valid doc on init' do
    response = AmazonAWS::Response.new(File.read('spec/response_xml/item_search_book_keyword.xml'))
    response.doc.should_not be_nil
  end
  
  it 'should return an array of <item>-rooted doc nodes from #items' do
    response = AmazonAWS::Response.new(File.read('spec/response_xml/item_search_book_keyword.xml'))
    items = response.items
    items.is_a?(Array).should == true
    items.length.should == 10
         
    items[0]%'item/asin'.should == '0743289358'
    items[1]%'item/salesrank'.should == '5483'
  end
  
  it 'should return an array of <cartitem>-rooted doc nodes from a Cart API call' do
    response = AmazonAWS::Response.new(File.read('spec/response_xml/cart_create_2_items.xml'))
    cart_items = response.cart_items
    cart_items.is_a?(Array).should == true
    cart_items.length.should == 2   
  end
  
  describe '#errors' do
    it 'should return the errors element from a response' do
      response = AmazonAWS::Response.new(File.read('spec/response_xml/item_search_no_matches.xml'))
      response.errors.should_not be_nil
      response.errors[:code].should == 'AWS.ECommerceService.NoExactMatches'
    end
  
    it 'should return nil if no errors (i.e., a good response' do
      response = AmazonAWS::Response.new(File.read('spec/response_xml/item_search_book_keyword.xml'))
      response.errors.should be_nil
    end
  end
end