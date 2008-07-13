module CartHelper

  def quantity_text(cart_item)
    return '' if cart_item.quantity == '1'
    
    "(#{cart_item.quantity} copies)"
  end
end