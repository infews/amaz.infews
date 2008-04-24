class ItemController < ApplicationController
  
  def index
    item_doc_node = aws_item_lookup(:asin => params[:asin]).items.first
    @item = ItemPresenter.new(item_doc_node) unless item_doc_node.nil?

    respond_to do |format|
      format.html # index.html.erb
    end
  end

end