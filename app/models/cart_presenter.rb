class CartPresenter < AwsPresenter
  
  attr_reader :items
  
  attr_from_xml :cart_id, '//cart/cartid'
  attr_from_xml :hmac, '//cart/hmac'
  attr_from_xml :purchase_url, '//cart/purchaseurl'
  attr_from_xml :url_encoded_hmac, '//cart/urlencodedhmac'

  def initialize(response)
    @doc = response.doc
    @items = response.cart_items.collect {|ci| CartItemPresenter.new(ci)}    
  end
  
  def subtotal
    @subtotal ||= get_price '//cart/subtotal'
  end
  
end