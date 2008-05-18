class ItemController < ApplicationController
  include ApplicationHelper #included for pluralize_with_delimiter
  
  def show
    first_item = aws_item_lookup(:asin => params[:asin]).items.first
    @item = ItemPresenter.new(first_item) unless first_item.nil?
    
    # TODO: if @item.nil? then we need to flash and redirect to search
    respond_to do |format|
      format.html
    end
  end
  
  def search
    @previous_search_index = params[:search_index]
    @previous_keywords     = params[:keywords]
    aws_response = aws_item_search(:keywords     => params[:keywords],                                
                                   :search_index => params[:search_index],
                                   :page         => params[:page])
    
    # TODO: handle bad results from amazon                              
    @results = SearchResultsPresenter.new(aws_response)
    # TODO: if @item.nil? then we need to flash and redirect to search
    respond_to do |format|
      format.html
    end
    
  end

  def self.search_types
    [['Books', 'Books'],
     ['Music', 'Music'  ],
     ['DVDs',  'DVD' ]]
  end
  
  # TODO: this doesn't work on FF!
  def test_show
    @item = ItemPresenter.new(Hpricot.parse(File.read('spec/response_xml/item_lookup_book.xml'))/:item)

    render :action => 'show'
  end
  
  def test_search
    
    @results = SearchResultsPresenter.new(AmazonAWS::Response.new(File.read('spec/response_xml/item_search_book_page_1.xml')))
    
    render :action => 'search'
  end
  
end