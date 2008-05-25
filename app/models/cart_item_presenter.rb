class CartItemPresenter < AwsPresenter

  attr_from_xml :cart_item_id, 'cartitemid'
  attr_from_xml :asin, 'asin'
  attr_from_xml :quantity, 'quantity'
  attr_from_xml :title, 'title'
  
  def initialize(doc)
    @doc = doc
  end
  
  # TODO: this can be refactored to a price_attr_from_xml method
  def price
    @price ||= get_price 'price'
  end
  
  def item_total
    @item_total ||= get_price 'itemtotal'
  end
end