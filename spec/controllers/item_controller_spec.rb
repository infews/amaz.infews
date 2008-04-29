require File.dirname(__FILE__) + '/../spec_helper'

describe ItemController do
  before :each do
    class << controller
      public(:aws_request)
    end
  end
   
  it 'should route to /item/123456' do 
    route_for(:controller => 'item', 
              :action => 'show',
              :asin => '123456').should == '/item/123456'
  end

  it 'should get routed from /item/123456' do
    params_from(:get, '/item/123456').should == {:controller => 'item',
                                                 :action     => 'show',
                                                 :asin       => '123456'}
  end

  it "should route to /item/search?search_type=book&keywords=foo" do 
    route_for(:controller => 'item', 
              :action => 'search',
              :search => 'book',
              :keywords => 'foo').should == '/item/search/book/foo'
  end

  it 'should get routed from /item/search?keywords=foo&search=book' do
    params_from(:get, '/item/search/book/foo').should == {:controller => 'item', 
                                                          :action => 'search',
                                                          :search => 'book',
                                                          :keywords => 'foo'}
  end

  it 'should call Amazon with an ItemLookup properly when an asin is requested and instantiate an ItemPresenter' do
    response_xml = File.read('spec/response_xml/item_lookup_book.xml')
    controller.aws_request.stub!(:fetch).and_return(response_xml)
    
    get 'show', :asin => '0143112562'
    
    assigns[:item].asin.should == '0143112562'
  end
  
  it 'should not instantiate an ItemPresenter if an item is not found' do
    response_xml = File.read('spec/response_xml/item_lookup_invalid.xml')
    controller.aws_request.stub!(:fetch).and_return(response_xml)
    
    get 'show', :asin => 'fffffffff'
    
    assigns[:item].should be_nil
  end
  
  it 'should tell the user that the item is not found' 
    
  it 'should redirect to an empty search page when an item is not found'
  
  it 'should call Amazon with a book keyword search' do
    response_xml = File.read('spec/response_xml/item_search_book_keyword.xml')
    controller.aws_request.stub!(:fetch).and_return(response_xml)
    
    get 'search', :search => 'book', :keywords => 'Against the day'
    
    assigns[:items].should_not be_nil   
    assigns[:items].size.should == 10
  end
end