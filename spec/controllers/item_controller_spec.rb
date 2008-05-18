require File.dirname(__FILE__) + '/../spec_helper'

describe ItemController do
  before :each do
    class << controller
      public(:aws_request)
    end
  end
  # Routing
  it 'should route to /item/show/123456' do 
    route_for(:controller => 'item', 
              :action => 'show',
              :asin => '123456').should == '/item/show/123456'
  end

  it 'should get routed from /item/123456' do
    params_from(:get, '/item/show/123456X').should == {:controller => 'item',
                                                       :action     => 'show',
                                                       :asin       => '123456X'}
  end

  it "should route to /item/search?search_type=book&keywords=foo" do 
    route_for(:controller => 'item', 
              :action => 'search',
              :search_index => 'Books',
              :keywords => 'foo').should == '/item/search/Books/foo'
  end

  it 'should get routed from /item/search?keywords=foo&search=book' do
    params_from(:post, "/item/search/Books/J%20K%20Rowling").should == {:controller => 'item', 
                                                            :action => 'search',
                                                            :search_index => 'Books',
                                                            :keywords => 'J K Rowling',
                                                            :page => '1'}
  end

  it "should route to /item/search/Books/foo%20bar/3" do 
    route_for(:controller => 'item', 
              :action => 'search',
              :search_index => 'Books',
              :keywords => 'foo bar',
              :page => '3').should == '/item/search/Books/foo%20bar/3'
  end

  it 'should get routed from /item/search/Books/foo%20bar/3' do
    params_from(:post, '/item/search/Books/foo%20bar/3').should == {:controller => 'item', 
                                                                    :action => 'search',
                                                                    :search_index => 'Books',
                                                                    :keywords => 'foo bar',
                                                                    :page => '3'}
  end

  it 'should get routed from /item/search/=foo&search=book&page=3' do
    params_from(:post, '/item/search/Books/foo/3').should == {:controller => 'item', 
                                                              :action => 'search',
                                                              :search_index => 'Books',
                                                              :keywords => 'foo',
                                                              :page => '3'}
  end
  
  
  # Actions
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
  
  it 'should call Amazon with a book keyword search' do
    response_xml = File.read('spec/response_xml/item_search_book_keyword.xml')
    controller.aws_request.stub!(:fetch).and_return(response_xml)
    
    get 'search', :search_index => 'Books', 
                  :keywords => 'Against the day', 
                  :page => '1'
    
    assigns[:results].should_not be_nil   
    assigns[:results].items.size.should == 10
  end
  
  it 'should support searching to an arbitrary page of search results' do
    response_xml = File.read('spec/response_xml/item_search_book_page_last.xml')
    controller.aws_request.stub!(:fetch).and_return(response_xml)
    
    get 'search', :search_index => 'Books', 
                  :keywords => 'harry potter', 
                  :page => '178'

    assigns[:results].should_not be_nil   
    assigns[:results].items.size.should == 1    
  end

  it 'should preserve the state of the previous seach' do
    response_xml = File.read('spec/response_xml/item_search_book_page_last.xml')
    controller.aws_request.stub!(:fetch).and_return(response_xml)

    get 'search', :search_index => 'Books', 
                  :keywords => 'Against the day', 
                  :page => '1'

    assigns[:previous_keywords].should == 'Against the day'
    assigns[:previous_search_index].should == 'Books'    
  end
  
  it 'should tell the user that the item is not found'     
  it 'should redirect to an empty search page when an item is not found'
  
end