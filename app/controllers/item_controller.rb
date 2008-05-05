class ItemController < ApplicationController
  include ApplicationHelper #included for pluralize_with_delimiter
  
  def show
    first_item = aws_item_lookup(:asin => params[:asin]).items.first
    @item = ItemPresenter.new(first_item) unless first_item.nil?
    
    # TODO: if @item.nil? then we need to flash and redirect to search
    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  def search
    aws_response = aws_item_search(:keywords     => params[:keywords],                                
                                   :search_index => 'Books',
                                   :page         => params[:page])
    
    # TODO: handle bad results from amazon                              
    @results = SearchResultsPresenter.new(aws_response)
    @search_message = "Searching Books for \"#{params[:keywords]}\""
    @results_count  = "Found #{pluralize_with_delimiter((aws_response.doc/:totalresults).innerHTML.to_i, 'item')}"
    @pages_info     = "page #{params[:page]} of #{number_with_delimiter((aws_response.doc/:totalpages).innerHTML.to_i)}"
    
    # TODO: if @item.nil? then we need to flash and redirect to search
    respond_to do |format|
      format.html # search.html.erb
    end
    
  end

  # TODO: this doesn't work on FF!
  def test_show
    @item = ItemPresenter.new(Hpricot.parse(File.read('spec/response_xml/item_lookup_book.xml'))/:item)

    render :template => 'show'
  end
  
end