class CartController < ApplicationController

  def add
    redirect_to '/' and return if params[:asin].nil?
    
    aws_response = if session[:cart].nil?
                     aws_create_cart(:asin => params[:asin])
                   else
                     aws_add_to_cart(:cart_id => session[:cart][:cart_id],
                                     :hmac    => session[:cart][:hmac],
                                     :asin    => params[:asin])
                   end
    @cart = CartPresenter.new(aws_response)    
    
    save_cart_in_session and return unless @cart.errors

    handle_errors
  end

  def update
    # TODO: protect against nil carts & incomplete params
    aws_response = aws_modify_cart(:cart_id      => session[:cart][:cart_id],
                                   :hmac         => session[:cart][:hmac],
                                   :quantity     => params[:quantity],
                                   :cart_item_id => params[:cart_item_id])
    @cart = CartPresenter.new(aws_response)
    
    save_cart_in_session and return unless @cart.errors
    
    handle_errors
  end

  def clear
    aws_response = aws_clear_cart(:cart_id => session[:cart][:cart_id],
                                  :hmac    => session[:cart][:hmac])
    @cart = CartPresenter.new(aws_response)

    if @cart.errors 
      handle_errors
    else
      session[:cart] = nil
      redirect_to '/'
    end
  end
  
  def show
    aws_response = aws_get_cart(:cart_id => session[:cart][:cart_id],
                                :hmac    => session[:cart][:hmac])
    @cart = CartPresenter.new(aws_response)
    
    save_cart_in_session and return unless @cart.errors
    
    handle_errors
  end
  
  protected
  
  def save_cart_in_session
    session[:cart] = {:cart_id => @cart.cart_id, :hmac => @cart.url_encoded_hmac}                                   
  end
  
  def handle_errors
    case @cart.errors[:code]
      when 'AWS.InternalError'
        flash[:info] = 'There was an error at Amazon.com. Please try again later.'
        save_cart_in_session
        redirect_to '/'
      when 'AWS.InvalidParameterValue'
        flash[:error] = 'There was an error with your request.'
        save_cart_in_session
        redirect_to '/'
      when 'AWS.ECommerceService.InvalidCartId', 
           'AWS.ECommerceService.InvalidHMAC'
        flash[:error]= 'This cart does not exist at Amazon.com.'
        session[:cart] = nil
        redirect_to '/'
      when 'AWS.ECommerceService.ItemAlreadyInCart'
        flash[:info] = 'This item is already in your cart.'
        save_cart_in_session
      when 'AWS.ECommerceService.ItemNotEligibleForCart'
        flash[:error] = 'This item is not eligible for this cart.'
        save_cart_in_session
        redirect_to '/'
      else
        flash[:error] = 'Whoops! There was an unknown error.'
        save_cart_in_session
        redirect_to '/'
    end
  end
end