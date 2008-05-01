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
    aws_response = aws_item_search(:keywords => params[:keywords],                                
                                :search_index => params[:search])
    @items = aws_response.items.collect {|i| ItemPresenter.new(i)}
    @search_message = "Searching #{params[:search].capitalize} for \"#{params[:keywords]}\""
    @results_count = "Found #{pluralize_with_delimiter(aws_response.doc/:totalresults, 'item')}"
    
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