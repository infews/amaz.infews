class CartController < ApplicationController

  before_filter :find_cart, :except => [:add, :test_show]

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
    
    handle_errors and return if @cart.errors

    save_cart_in_session
    render :action => 'show'
  end

  def update
    aws_response = aws_modify_cart(:cart_id      => session[:cart][:cart_id],
                                   :hmac         => session[:cart][:hmac],
                                   :quantity     => params[:quantity],
                                   :cart_item_id => params[:cart_item_id])
    @cart = CartPresenter.new(aws_response)
    
    # TODO: need to test drive this case; if there are no items left 
    redirect_to(:action => 'clear') and return if @cart.items.empty?
    
    handle_errors and return if @cart.errors

    save_cart_in_session
    render :action => 'show'
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
    
    handle_errors and return if @cart.errors
    
    save_cart_in_session    
  end
  
  def test_show
    session[:cart] = {:cart_id => '104-9487830-8806330',
                      :hmac => 'Ze%2B9VNGLN3MRlgl2go%2FxH8aoiMY%3D' }
    @cart = CartPresenter.new(AmazonAWS::Response.new(File.read('spec/response_xml/cart_get_cart_B.xml')))
    render :action => 'show'
  end
  
  protected

  def find_cart
    if session[:cart].blank? || session[:cart][:cart_id].blank? || session[:cart][:hmac].blank?
      flash[:error] = "Unable to find that cart"
      redirect_to '/'
      return false
    end
  end
  
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