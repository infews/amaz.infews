require File.dirname(__FILE__) + '/../spec_helper'

describe SearchResultsPresenter do
  
  before :all do
    @book_keyword_search = AmazonAWS::Response.new(File.read('spec/response_xml/item_search_book_page_1.xml')) 
    @book_bestsellers_search = AmazonAWS::Response.new(File.read('spec/response_xml/item_search_book_bestsellers.xml')) 
  end
  
  it 'should store the ItemPresenters from a response' do
    results = SearchResultsPresenter.new(@book_keyword_search)
    
    results.items.size.should == 10
  end  
  
  it 'should present the current page' do
    results = SearchResultsPresenter.new(@book_keyword_search)
    
    results.page.should == '1'
  end
  
  it 'should present the total pages' do
    results = SearchResultsPresenter.new(@book_keyword_search)
    
    results.total_pages.should == '178'
  end
    
  it 'should present the total number of results' do
    results = SearchResultsPresenter.new(@book_keyword_search)
    
    results.total_results.should == '1771'
  end
  
  it "should tell the template if it's on the first page" do
    results = SearchResultsPresenter.new(@book_keyword_search)
    
    results.first_page?.should == true
    results.last_page?.should == false
  end
  
  it "should tell the template if it's on the last page" do
    last_page = AmazonAWS::Response.new(File.read('spec/response_xml/item_search_book_page_last.xml'))
    results = SearchResultsPresenter.new(last_page)
    
    results.first_page?.should == false
    results.last_page?.should == true
  end

  it 'should show the search type and terms' do
    results = SearchResultsPresenter.new(@book_keyword_search)
    
    results.message.should == "Searching Books for \"harry potter\""
  end
  
  it 'should show the current page and the total number of pages' do
    results = SearchResultsPresenter.new(@book_keyword_search)
    
    results.page_info.should == 'page 1 of 178'
  end
  
  it 'should preserve the Amazon search index' do
    results = SearchResultsPresenter.new(@book_keyword_search)
    
    results.search_index.should == 'Books'
  end
  
  it 'should preserve the search keywords' do
    results = SearchResultsPresenter.new(@book_keyword_search)
    
    results.keywords.should == 'harry potter' 
  end
  
  it 'should tell that it is a bestseller search' do
    results = SearchResultsPresenter.new(@book_bestsellers_search)
    results.bestseller_search?.should == true
  end
  
  it 'should tell that it is NOT a bestseller search' do
    results = SearchResultsPresenter.new(@book_keyword_search)
    results.bestseller_search?.should == false
  end
  
end