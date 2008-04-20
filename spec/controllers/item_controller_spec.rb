require File.dirname(__FILE__) + '/../spec_helper'

describe ItemController do

  it 'should route to /item/123456' do 
    route_for(:controller => 'item', 
              :action => 'index',
              :asin => '123456').should == '/item/123456'
  end

  it 'should get routed from /item/123456' do
    params_from(:get, '/item/123456').should == {:controller => 'item',
                                                 :action => 'index',
                                                 :asin => '123456'}
  end

  it 'should call the Amazon library properly when an asin is requested' do
    controller.should_receive(:ecs_item_lookup).with(:asin => '123456').and_return('foo')
    
    get 'index', :asin => '123456'
    
    assigns[:item].should == 'foo'
  end
  # verify that we call ecs properly in bad cases
  
  it 'should retrieve all the required Item fields from the Response 
      that are needed for a detail view on a Book' do
    mocked_response_body = File.read('spec/item_lookup_book.xml')
    AmazonECS::Request.stub!(:fetch).and_return(mocked_response_body)

    get 'index', :asin => '159420120X'
    
    item = assigns[:item]

    item.title.should      == 'Against the Day'
    item.binding.should    == 'Hardcover'
    item.edition.should    be_nil
    item.author.should     == 'Thomas Pynchon'
    item.sales_rank.should == '878'
    item.list_price.formatted_price.should         == '$35.00'
    item.offers[0].price.formatted_price.should    == '$7.00'
    item.customer_reviews.average_rating.should    == '4.5'
    item.customer_reviews.number_of_reviews.should == '38'
    # TODO: image
    # TODO: description
  end
  
end
