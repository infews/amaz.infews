require 'rubygems'
##require File.dirname(__FILE__) + '/../spec_helper'

require 'lib/amazon_aws'

describe AmazonAWS::Response do
  
  it 'should have a valid doc on init' do
    response = AmazonAWS::Response.new(File.read('spec/response_xml/item_search_book_keyword.xml'))
    response.doc.should_not be_nil
  end
  
  it 'should return an array of <item>-rooted doc nodes from #items' do
    response = AmazonAWS::Response.new(File.read('spec/response_xml/item_search_book_keyword.xml'))
    items = response.items
    items.length.should == 10
    items.is_a?(Array).should == true
         
    items[0]%'item/asin'.should == '0743289358'
    items[1]%'item/salesrank'.should == '5483'
  end
  
end