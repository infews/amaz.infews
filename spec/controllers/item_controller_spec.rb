require File.dirname(__FILE__) + '/../spec_helper'

# TODO: stub out the calls to the library instead of stubbing out fetch

describe ItemController, '#show' do
  before :each do
    class << controller
      public(:aws_request)
    end
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
end

describe ItemController, '#search' do
  before :each do
    class << controller
      public(:aws_request)
    end
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

  it 'should support a search for book bestsellers' do
    response_xml = File.read('spec/response_xml/item_search_book_bestsellers.xml')
    controller.aws_request.stub!(:fetch).and_return(response_xml)
    get 'search', :search_index => 'Books', 
                  :bestsellers => 'true'
    assigns[:previous_search_index].should == 'Books'    
  end
   
  it 'should tell the user that the item is not found'     
  it 'should redirect to an empty search page when an item is not found'
  
end