require 'rubygems'

gem 'rspec'
require 'spec'
#require File.dirname(__FILE__) + '/../spec_helper'

require 'lib/amazon_aws'

# dummy ECSClient class, just for testing
class AWSClient
  include AmazonAWS
  
  def amazon_associates_id
    'test-20'
  end
  
  def amazon_access_key    
    '12345678'
  end
end

describe AmazonAWS do
  before :all do
    @client = AWSClient.new
    class << @client
      public(:aws_request)
    end
  end
  
  it 'should call CartClear with the correct URL' do
    url = 'http://webservices.amazon.com/onca/xml?Service=AWSECommerceService' + 
          '&AWSAccessKeyId=12345678&AssociateTag=test-20' +
          '&Operation=CartClear&CartId=12&HMAC=ABC'
    @client.aws_request.stub!(:fetch).with(url).and_return('ok')
    
    @client.aws_clear_cart(:aws_cart_id => '12', :hmac => 'ABC')
  end
  
  it 'should call CartAdd to add one item with the correct URL' do
    url = 'http://webservices.amazon.com/onca/xml?Service=AWSECommerceService' +
          '&AWSAccessKeyId=12345678&AssociateTag=test-20' +
          '&Operation=CartAdd&CartId=12&HMAC=ABC' +
          '&Item.1.ASIN=12345678&Item.1.Quantity=1'
    @client.aws_request.stub!(:fetch).with(url).and_return('ok')
  
    @client.aws_add_to_cart(:aws_cart_id => '12', 
                                   :hmac => 'ABC',
                                   :asin => ['12345678'])
  end

  it 'should call CartAdd to add multiple items with the correct URL' do
    url = 'http://webservices.amazon.com/onca/xml?Service=AWSECommerceService' +
          '&AWSAccessKeyId=12345678&AssociateTag=test-20' +
          '&Operation=CartAdd&CartId=12&HMAC=ABC' +
          '&Item.1.ASIN=12345678&Item.1.Quantity=1' +
          '&Item.2.ASIN=abcdefgh&Item.2.Quantity=1'
    @client.aws_request.stub!(:fetch).with(url).and_return('ok')
  
    @client.aws_add_to_cart(:aws_cart_id => '12', 
                            :hmac => 'ABC',
                            :asin => ['12345678', 'abcdefgh'])
  end

  it 'should call CartCreate with the correct URL' do
    url = 'http://webservices.amazon.com/onca/xml?Service=AWSECommerceService' +
          '&AWSAccessKeyId=12345678&AssociateTag=test-20' +
          '&Operation=CartCreate' +
          '&Item.1.ASIN=12345678&Item.1.Quantity=1'
    @client.aws_request.stub!(:fetch).with(url).and_return('ok')
  
    @client.aws_create_cart(:asin => ['12345678'])
  end

  
  it 'should call CartCreate with multiple items with the correct URL' do
    url = 'http://webservices.amazon.com/onca/xml?Service=AWSECommerceService' +
          '&AWSAccessKeyId=12345678&AssociateTag=test-20' +
          '&Operation=CartCreate' +
          '&Item.1.ASIN=12345678&Item.1.Quantity=1' +
          '&Item.2.ASIN=abcdefgh&Item.2.Quantity=1'
    @client.aws_request.stub!(:fetch).with(url).and_return('ok')

    @client.aws_create_cart(:asin => ['12345678', 'abcdefgh'])
  end

  it 'should call CartGet with the correct URL' do
    url = 'http://webservices.amazon.com/onca/xml?Service=AWSECommerceService' +
          '&AWSAccessKeyId=12345678&AssociateTag=test-20' +
          '&Operation=CartGet&CartId=12&HMAC=ABC'
    @client.aws_request.stub!(:fetch).with(url).and_return('ok')
  
    @client.aws_get_cart(:aws_cart_id => '12', 
                                :hmac => 'ABC')
  end

  it 'should call CartModify with the correct URL' do
    url = 'http://webservices.amazon.com/onca/xml?Service=AWSECommerceService' +
          '&AWSAccessKeyId=12345678&AssociateTag=test-20' +
          '&Operation=CartModify&CartId=12&HMAC=ABC' + 
          '&Item.1.CartItemId=1&Item.1.Quantity=2'    
    @client.aws_request.stub!(:fetch).with(url).and_return('ok')

    @client.aws_modify_cart(:aws_cart_id  => '12', 
                                   :hmac         => 'ABC',
                                   :cart_item_id => 1,
                                   :quantity     => 2)
  end
  
  it 'should call ItemLookup with the correct URL' do
    url = 'http://webservices.amazon.com/onca/xml?Service=AWSECommerceService' +
          '&AWSAccessKeyId=12345678&AssociateTag=test-20' +
          '&ItemId=12345678&Operation=ItemLookup&ResponseGroup=Large'
    @client.aws_request.stub!(:fetch).with(url).and_return('ok')

    @client.aws_item_lookup(:asin => '12345678')
   end
  
  it 'should call ItemSearch for an actor with defaults with the correct URL' do
    url = 'http://webservices.amazon.com/onca/xml?Service=AWSECommerceService' +
          '&AWSAccessKeyId=12345678&AssociateTag=test-20' +
          '&Actor=Ian%20McKellen&Availability=Available&MerchantId=Amazon&Condition=All' +
          '&Operation=ItemSearch&ResponseGroup=Medium,Offers'
          
    @client.aws_request.stub!(:fetch).with(url).and_return('ok')
  
    @client.aws_item_search({:actor => 'Ian McKellen'})
  end

  it 'should call ItemSearch for an artist with some default overriedes with the correct URL' do
    url = 'http://webservices.amazon.com/onca/xml?Service=AWSECommerceService' +
          '&AWSAccessKeyId=12345678&AssociateTag=test-20' +
          '&Artist=The%20Beatles' +
          '&Availability=Available&MerchantId=Amazon&Condition=All' +
          '&Operation=ItemSearch&ResponseGroup=Large,Offers'
    @client.aws_request.stub!(:fetch).with(url).and_return('ok')
    
    @client.aws_item_search({:artist => 'The Beatles', :response_group => 'Large,Offers'})
  end

  it 'should call ItemSearch for an author with a different browse node with the correct URL' do
    url = 'http://webservices.amazon.com/onca/xml?Service=AWSECommerceService' +
          '&AWSAccessKeyId=12345678&AssociateTag=test-20' +
          '&Author=Don%20King' +
          '&Availability=Available&MerchantId=Amazon&Condition=All' +
          '&BrowseNode=Foo' +
          '&Operation=ItemSearch&ResponseGroup=Medium,Offers'
    @client.aws_request.stub!(:fetch).with(url).and_return('ok')

    @client.aws_item_search({:author => 'Don King', :browse_node => 'Foo'})
  end

  it 'should call ItemSearch for a director with a different item page with the correct URL' do
    url = 'http://webservices.amazon.com/onca/xml?Service=AWSECommerceService' +
          '&AWSAccessKeyId=12345678&AssociateTag=test-20' +
          '&Availability=Available&MerchantId=Amazon&Condition=All' +
          '&Director=Alan%20Smithee' +
          '&ItemPage=2' +
          '&Operation=ItemSearch&ResponseGroup=Medium,Offers'
    @client.aws_request.stub!(:fetch).with(url).and_return('ok')
    
    @client.aws_item_search({:director => 'Alan Smithee', :item_page => '2'})
  end

  it 'should call ItemSearch for keywords with a search index with the correct URL' do
    url = 'http://webservices.amazon.com/onca/xml?Service=AWSECommerceService' +
          '&AWSAccessKeyId=12345678&AssociateTag=test-20' +
          '&Availability=Available&MerchantId=Amazon&Condition=All' +
          '&Keywords=foo%20bar' +
          '&Operation=ItemSearch&ResponseGroup=Medium,Offers' +
          '&SearchIndex=Baz'
    @client.aws_request.stub!(:fetch).with(url).and_return('ok')

    @client.aws_item_search({:keywords => 'foo bar', :search_index => 'Baz'})
  end

  it 'should call ItemSearch for keywords with a search index with the correct URL' do
    url = 'http://webservices.amazon.com/onca/xml?Service=AWSECommerceService' +
          '&AWSAccessKeyId=12345678&AssociateTag=test-20' +
          '&Availability=Available&MerchantId=Amazon&Condition=All' +
          '&Keywords=foo%20bar' +
          '&Operation=ItemSearch&ResponseGroup=Medium,Offers' +
          '&SearchIndex=Baz'
    @client.aws_request.stub!(:fetch).with(url).and_return('ok')
    
    @client.aws_item_search({:keywords => 'foo bar', :search_index => 'Baz'})    
  end

  it 'should call ItemSearch for a title with a sort value with the correct URL' do
    url = 'http://webservices.amazon.com/onca/xml?Service=AWSECommerceService' +
          '&AWSAccessKeyId=12345678&AssociateTag=test-20' +
          '&Availability=Available&MerchantId=Amazon&Condition=All' +
          '&Operation=ItemSearch&ResponseGroup=Medium,Offers' +
          '&Sort=foo' +
          '&Title=Vineland'
    @client.aws_request.stub!(:fetch).with(url).and_return('ok')

    @client.aws_item_search({:title=> 'Vineland', :sort => 'foo'})
  end  

  it 'should get a valid ItemResponse when making an ItemLookup request' do
    mocked_response_body = File.read('spec/response_xml/item_lookup_book.xml')
    url = 'http://webservices.amazon.com/onca/xml?Service=AWSECommerceService' +
          '&AWSAccessKeyId=12345678&AssociateTag=test-20' +
          '&ItemId=12345678&Operation=ItemLookup&ResponseGroup=Large'
    @client.aws_request.stub!(:fetch).with(url).and_return(mocked_response_body)

    item_response = @client.aws_item_lookup(:asin => '12345678') 
    item_response.class.should == AmazonAWS::Response
  end
  
end