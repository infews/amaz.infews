class CartController < ApplicationController

  def add
    #TODO: validate that there is a params[:asin]
    if session[:cart].nil?
      aws_response = aws_create_cart(:asin => params[:asin])
    else
      # TODO: validate cart in session?
      aws_response = aws_add_to_cart(:aws_cart_id => session[:cart][:cart_id],
                                     :hmac => session[:cart][:hmac],
                                     :asin => params[:asin])
    end
    @cart = CartPresenter.new(aws_response)
    session[:cart] = {:cart_id => @cart.cart_id, :hmac => @cart.url_encoded_hmac}                                   
    
    # TODO: handle cart that comes back empty/expired      
  end

  def update
    # TODO: protect against nil carts & incomplete params
    aws_response = aws_modify_cart(:aws_cart_id => session[:cart][:cart_id],
                                   :hmac => session[:cart][:hmac],
                                   :quantity => params[:quantity],
                                   :cart_item_id => params[:cart_item_id])
    @cart = CartPresenter.new(aws_response)
    session[:cart] = {:cart_id => @cart.cart_id, :hmac => @cart.url_encoded_hmac}                                   
  end

  def clear
    aws_response = aws_clear_cart(:aws_cart_id => session[:cart][:cart_id],
                                  :hmac => session[:cart][:hmac])
    @cart = CartPresenter.new(aws_response)
    session[:cart] = nil
    redirect_to '/'
  end
end