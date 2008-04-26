class ItemController < ApplicationController
  
  def show
    first_item = aws_item_lookup(:asin => params[:asin]).items.first
    @item = ItemPresenter.new(first_item) unless first_item.nil?
    # TODO: if @item.nil? then we need to flash and redirect to search
    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  def search
    all_items = aws_item_search(:keywords => params[:keywords],
                                :search_type => params[:search],
                                :search_index => 'Books').items
    @items = all.items.collect {|i| ItemPresenter.new(i)}
    # TODO: if @item.nil? then we need to flash and redirect to search
    respond_to do |format|
      format.html # search.html.erb
    end
    
  end

end