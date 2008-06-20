class ItemController < ApplicationController
  
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
    options = {:search_index => params[:search_index],
               :page         => params[:page] || '1'}
             
    if params['bestsellers'] || params[:bestsellers]
      options.merge!(:sort => 'salesrank',
                     :browse_node => ItemController.bestseller_browse_node_for(params[:search_index]))
    else
      options.merge!(:keywords => params[:keywords])
    end

    aws_response = aws_item_search(options)
    
    # TODO: handle bad results from amazon                              
    @results = SearchResultsPresenter.new(aws_response)
    # TODO: if @item.nil? then we need to flash and redirect to search
    respond_to do |format|
      format.html
    end
    
  end
  
  # TODO: this doesn't work on FF3b5 when not connected to WiFi!
  def test_show
    @item = ItemPresenter.new(Hpricot.parse(File.read('spec/response_xml/item_lookup_book.xml'))/:item)

    render :action => 'show'
  end
  
  def test_search
    
    @results = SearchResultsPresenter.new(AmazonAWS::Response.new(File.read('spec/response_xml/item_search_book_page_1.xml')))
    
    render :action => 'search'
  end

  private
  
  def self.search_types
    [['Books', 'Books'],
     ['Music', 'Music'  ],
     ['DVDs',  'DVD' ]]
  end
  
  def self.bestseller_browse_node_for(search_index)
    case search_index
      when 'Books' then '1000'
      when 'Music' then '301688'
      when 'DVD'   then '130'
      else ''
    end
  end
  
end