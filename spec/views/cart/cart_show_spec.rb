require File.dirname(__FILE__) + '/../../spec_helper'

describe '/cart/show' do
  before :each do
    @cart_response = AmazonAWS::Response.new(File.read('spec/response_xml/cart_create_2_items.xml')) 
  end
  
  it 'should show a cart\'s basic information, if any' do
    assigns[:cart] = CartPresenter.new(@cart_response)
    
    render '/cart/show'
    
    response.should have_tag('div.cart_header') do
      with_tag('div.message', 'Your Cart')
    end
  end
  
  it 'should show all of the cart\'s items with titles linked to each\'s details page' do
    assigns[:cart] = CartPresenter.new(@cart_response)
    
    render '/cart/show'

    response.should have_tag('div.cart_item') do
      with_tag('div.title') do
        with_tag('a[href=/item/show/0143112562]', 'Against the Day')
      end
    end

    response.should have_tag('div.cart_item') do
      with_tag('div.title') do
        with_tag('a[href=/item/show/B00001ZWUS]', 'Saving Private Ryan (Special Limited Edition)')
      end
    end

  end
  
  it 'should show each item\'s subtotal' do
    assigns[:cart] = CartPresenter.new(@cart_response)
    
    render '/cart/show'

    response.should have_tag('div.cart_item') do
      with_tag('div.amount', '$24.48')
    end

    response.should have_tag('div.cart_item') do
      with_tag('div.amount', '$10.99')
    end
    
  end
  
  it 'should have the cart item\'s UI for +1, -1, remove' do
    assigns[:cart] = CartPresenter.new(@cart_response)
    
    render '/cart/show'

    response.should have_tag('div.cart_item') do
      with_tag('div.actions') do
        with_tag('a[href=/cart/update/UZ505BDU01ZH0/3]')
        with_tag('a[href=/cart/update/UZ505BDU01ZH0/1]')
        with_tag('a[href=/cart/update/UZ505BDU01ZH0/0]')
      end
    end
  end

  it 'should have the "remove all items and delete this cart" link' do
    assigns[:cart] = CartPresenter.new(@cart_response)
    
    render '/cart/show'

    response.should have_tag('div.cart_actions') do
      with_tag('a[href=/cart/clear]', 'Empty Cart')
    end
    
  end

  it 'should have the cart\'s subtotal listed' do
    assigns[:cart] = CartPresenter.new(@cart_response)
    
    render '/cart/show'

    response.should have_tag('div.cart_subtotal') do
      with_tag('span.subtotal', 'Cart Subtotal:')
      with_tag('span.amount', '$35.47')
    end

  end

  it 'should have a link to buy this cart at Amazon' do
    assigns[:cart] = CartPresenter.new(@cart_response)
    
    render '/cart/show'
    
    response.should have_tag('div.cart_actions') do
      with_tag('a', 'Checkout')
    end
    
  end
  
end