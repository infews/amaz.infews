require File.dirname(__FILE__) + '/../../spec_helper'

describe '/item/search' do
  before :all do
    @book_keyword_search = AmazonAWS::Response.new(File.read('spec/response_xml/item_search_book_keyword.xml')) 
  end
  
  it 'should tell the user what the search terms were' do
    assigns[:items] = @book_keyword_search.items.collect {|i| ItemPresenter.new(i)}
    assigns[:search_message] = 'Searching Books for "Against the Day"'
    assigns[:results_count] = 'Found 338 items'

    render 'item/search'
    
    response.should have_tag('div#messages') do
      with_tag('div#search_message', 'Searching Books for "Against the Day"')
    end
  end
  
  it 'should have items on the page' do
    assigns[:items] = @book_keyword_search.items.collect {|i| ItemPresenter.new(i)}
    assigns[:search_message] = 'Searching Books for "Against the Day"'
    assigns[:results_count] = 'Found 338 items'
    
    render 'item/search'
    
    response.should have_tag('div.item', :count => 10)
  end
  
  it 'should not have items that do not have offers from Amazon'
  
  it 'should show a count of search results' do
    assigns[:items] = @book_keyword_search.items.collect {|i| ItemPresenter.new(i)}
    assigns[:search_message] = 'Searching Books for "Against the Day"'
    assigns[:results_count] = 'Found 338 items'
    
    render 'item/search'
    
    response.should have_tag('div#messages') do
      with_tag('div#results_count', 'Found 338 items')
    end
  end
  
  it 'should show the current page within the search results'
  it 'should show the number of pages of search results'
  # TODO: should the summary tests be in a separate partial test?
  it 'should have the titles linked to detail pages' do
    assigns[:items] = @book_keyword_search.items.collect {|i| ItemPresenter.new(i)}
    assigns[:search_message] = 'Searching Books for "Against the Day"'
    assigns[:results_count] = 'Found 338 items'
    
    render 'item/search'
    
    response.should have_tag('div.item') do
      with_tag('a', 'Play Dirty: A Novel')
    end
    
  end
  it 'should have the authors linked to new searches'
  
  it 'should not have have a previous link on the first page'
  it 'should not have the next link on the last page'
  it 'should have a search form on the page' # TODO: should this be in layout testing?
  it 'should default the search form to the last search'
end