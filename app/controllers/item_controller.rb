=begin
AWS.InvalidParameterValue
AWS.ECommerceService.ItemNotAccessible
AWS.ECommerceService.NoExactMatches
=end

class ItemController < ApplicationController
  
  def show
    aws_response = aws_item_lookup(:asin => params[:asin])
    # set flash
    redirect_to '/' and return if aws_response.errors || aws_response.items.nil?
    @item = ItemPresenter.new(aws_response.items.first)
    
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
    
    @results = SearchResultsPresenter.new(aws_response)
    # TODO: flash for no results
    respond_to do |format|
      format.html
    end
    
  end
  
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

  # TODO: this belongs in AmazonAWS
  def self.bestseller_browse_node_for(search_index)
    case search_index
      when 'Books' then '1000'
      when 'Music' then '301688'
      when 'DVD'   then '130'
      else ''
    end
  end
  
end