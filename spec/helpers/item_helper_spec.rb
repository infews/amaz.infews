require File.dirname(__FILE__) + '/../spec_helper'

describe ItemHelper, '#other_page_of_results' do
  
  before(:each) do
    class << helper
      public(:other_page_of_results)
    end
  end
  
  it 'should make a URL for another page of bestseller search results' do
    results = mock('results')
    results.stub!(:bestseller_search?).and_return(true)
    results.stub!(:search_index).and_return('Books')
    
    helper.other_page_of_results(results, '1').should == '/item/bestsellers/Books/1'
  end
  
  it 'should make a URL for another page of search results' do
    results = mock('results')
    results.stub!(:bestseller_search?).and_return(false)
    results.stub!(:search_index).and_return('Books')
    results.stub!(:keywords).and_return('foo bar')
    
    helper.other_page_of_results(results, '3').should == '/item/search/Books/foo%20bar/3'
  end

  it 'should route search_path with escaped params' do
    class << helper
      public(:search_path)
    end

    helper.search_path(:search_index => 'Books',
                           :keywords => CGI::escape('ISO/TC 22/SC 3')).should == '/item/search/Books/ISO%252FTC+22%252FSC+3'
  end
end