class CartController < ApplicationController

  def add
    redirect_to '/' and return if params[:asin].nil?
    
    aws_response = if session[:cart].nil?
                     aws_create_cart(:asin => params[:asin])
                   else
                     aws_add_to_cart(:aws_cart_id => session[:cart][:cart_id],
                                     :hmac => session[:cart][:hmac],
                                     :asin => params[:asin])
                   end
    @cart = CartPresenter.new(aws_response)    
    
    unless @cart.valid?
      session[:cart] = nil
      redirect_to '/' and return
    end    
    
    save_cart_in_session
    
    # TODO: handle cart that comes back empty/expired      
  end

  def update
    # TODO: protect against nil carts & incomplete params
    aws_response = aws_modify_cart(:aws_cart_id => session[:cart][:cart_id],
                                   :hmac => session[:cart][:hmac],
                                   :quantity => params[:quantity],
                                   :cart_item_id => params[:cart_item_id])
    @cart = CartPresenter.new(aws_response)
    redirect_to '/' unless @cart.valid?
    
    save_cart_in_session
  end

  def clear
    aws_response = aws_clear_cart(:aws_cart_id => session[:cart][:cart_id],
                                  :hmac => session[:cart][:hmac])
    @cart = CartPresenter.new(aws_response)
    session[:cart] = nil
    redirect_to '/'
  end
  
  def show
    aws_response = aws_get_cart(:aws_cart_id => session[:cart][:cart_id],
                                :hmac => session[:cart][:hmac])
    @cart = CartPresenter.new(aws_response)
    
    redirect_to '/' unless @cart.valid?
    save_cart_in_session
  end
  
  protected
  
  def save_cart_in_session
    session[:cart] = {:cart_id => @cart.cart_id, :hmac => @cart.url_encoded_hmac}                                   
  end
end