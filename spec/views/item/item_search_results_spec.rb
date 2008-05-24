require File.dirname(__FILE__) + '/../../spec_helper'

describe '/item/search' do
  before :all do
    @book_keyword_search = AmazonAWS::Response.new(File.read('spec/response_xml/item_search_book_keyword.xml')) 
  end
  
  it 'should tell the user what the search terms were' do
    assigns[:results] = SearchResultsPresenter.new(@book_keyword_search)
    params[:search] = 'Books'
    params[:keywords] = 'Against the day'
    params[:page] = '1'

    render 'item/search'
    
    response.should have_tag('div#messages') do
      with_tag('div#search_message', 'Searching Books for "Against the day"')
    end
  end
  
  it 'should have items on the page' do
    assigns[:results] = SearchResultsPresenter.new(@book_keyword_search)
    params[:search] = 'Books'
    params[:keywords] = 'Against the day'
    params[:page] = '1'
    
    render 'item/search'
    
    response.should have_tag('div.item', :count => 10)
  end
  
  it 'should not have items that do not have offers from Amazon'
  
  it 'should show a count of search results' do
    assigns[:results] = SearchResultsPresenter.new(@book_keyword_search)
    params[:search] = 'Books'
    params[:keywords] = 'Against the day'
    params[:page] = '1'
    
    render 'item/search'
    
    response.should have_tag('div#messages') do
      with_tag('div#results_count', 'Found 338 items')
    end
  end
  
  # TODO: should the summary tests be in a separate partial test?
  it 'should have the titles linked to detail pages' do
    assigns[:results] = SearchResultsPresenter.new(@book_keyword_search)
    params[:search] = 'Books'
    params[:keywords] = 'Against the day'
    params[:page] = '1'
    
    render 'item/search'
    
    response.should have_tag('div.item') do
      with_tag('a', 'Play Dirty: A Novel')
    end
   
  end
  
  it 'should show the current page and number of pages within the search results' do
    assigns[:results] = SearchResultsPresenter.new(@book_keyword_search)
    params[:search] = 'Books'
    params[:keywords] = 'Against the day'
    params[:page] = '1'
    
    render 'item/search'
    
    response.should have_tag('div#results_pages', assigns[:pages_info])
  end
   
  it 'should not have have a previous link on the first page' do
    page_one = AmazonAWS::Response.new(File.read('spec/response_xml/item_search_book_page_1.xml')) 
    assigns[:results] = SearchResultsPresenter.new(page_one)
    params[:search] = 'Books'
    params[:keywords] = 'harry potter'
    params[:page] = '1'
    
    render 'item/search'
    
    response.should have_tag('div#page_nav') do
      with_tag('div#prev') do
        without_tag('a')
      end
      with_tag('div#next') do
        with_tag('a')
      end
    end
  end
  
  it 'should have both next and previous link on "middle" pages' do
    page_two = AmazonAWS::Response.new(File.read('spec/response_xml/item_search_book_page_2.xml')) 
    assigns[:results] = SearchResultsPresenter.new(page_two)
    params[:search] = 'Books'
    params[:keywords] = 'harry potter'
    params[:page] = '2'

    render 'item/search'
    
    response.should have_tag('div#page_nav') do      
      with_tag('div#prev') do
        with_tag('a')
      end
      with_tag('div#next') do
        with_tag('a')
      end
    end
  end

  it 'should not have the next link on the last page' do
    last_page = AmazonAWS::Response.new(File.read('spec/response_xml/item_search_book_page_last.xml')) 
    assigns[:results] = SearchResultsPresenter.new(last_page)
    params[:search] = 'Books'
    params[:keywords] = 'harry potter'
    params[:page] = '178'

    render 'item/search'
    
    response.should have_tag('div#page_nav') do      
      with_tag('div#prev') do
        with_tag('a')
      end
      with_tag('div#next') do
        without_tag('a')
      end
    end
  end
end

describe '/item/search', 'for Bestsellers' do
  
  before :all do
    @book_bestsellers_search = AmazonAWS::Response.new(File.read('spec/response_xml/item_search_book_bestsellers.xml')) 
  end
  
  it 'should render bestsellers results just like normal search results' do
    assigns[:results] = SearchResultsPresenter.new(@book_bestsellers_search)
    params[:search] = 'Books'
    params[:keywords] = nil
    params[:page] = 1
    
    render 'item/search'
    
    response.should have_tag('div#page_nav') do
      with_tag('div#prev') do
        without_tag('a')
      end
      with_tag('div#next') do
        with_tag('a')
      end
    end
  end
  
end