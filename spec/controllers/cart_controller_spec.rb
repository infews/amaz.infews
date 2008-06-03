require File.dirname(__FILE__) + '/../spec_helper'

describe CartController do
  
  describe '#add' do    
    
    before :all do
      @create_cart_doc = Hpricot.parse(File.open('spec/response_xml/cart_create.xml', 'r'))
      @add_to_cart_doc = Hpricot.parse(File.open('spec/response_xml/cart_add_cart_B.xml', 'r'))
      @bad_cart_doc   = Hpricot.parse(File.open('spec/response_xml/cart_get_cart_bad_cart.xml'))
    end

    it 'should create a new cart with this item if one does not exist in the session' do
      session[:cart] = nil      
      aws_response = mock('create_cart_aws_response')
      aws_response.should_receive(:doc).and_return(@create_cart_doc)
      aws_response.should_receive(:cart_items).twice.and_return(@create_cart_doc/'cart/cartitems/cartitem'.inject([]) {|a, i| a << i})
      controller.should_receive(:aws_create_cart).with({:asin => '0143112562'}).once.and_return(aws_response)
      
      get :add, :asin => '0143112562'      
    end
    
    it 'should initialize a CartPresenter from the Amazon aws_response' do
      session[:cart] = nil      
      aws_response = mock('create_cart_aws_response')
      aws_response.should_receive(:doc).and_return(@create_cart_doc)
      aws_response.should_receive(:cart_items).twice.and_return(@create_cart_doc/'cart/cartitems/cartitem'.inject([]) {|a, i| a << i})
      controller.should_receive(:aws_create_cart).with({:asin => '0143112562'}).once.and_return(aws_response)
      
      get :add, :asin => '0143112562'      

      assigns[:cart].should_not be_nil
      assigns[:cart].class.should == CartPresenter
      assigns[:cart].items.length.should == 1
    end

    it 'should store a new cart in the session if one was created' do
      session[:cart] = nil
      aws_response = mock('create_cart_aws_response')
      aws_response.should_receive(:doc).and_return(@create_cart_doc)
      aws_response.should_receive(:cart_items).twice.and_return(@create_cart_doc/'cart/cartitems/cartitem'.inject([]) {|a, i| a << i})
      controller.should_receive(:aws_create_cart).with({:asin => '0143112562'}).once.and_return(aws_response)
      
      get :add, :asin => '0143112562'      
      
      session[:cart].should == {:cart_id => '102-3956189-4078545', :hmac => 'AguWLSvYLDztxNj7OD7IpZRyUGI%3D'}        
    end
    
    it 'should add a new cart item to an existing cart' do
      session[:cart] = {:cart_id => '104-9487830-8806330', :hmac => 'Ze%2B9VNGLN3MRlgl2go%2FxH8aoiMY%3D'}        
      aws_response = mock('add_to_cart_aws_response')
      aws_response.should_receive(:doc).and_return(@add_to_cart_doc)
      aws_response.should_receive(:cart_items).twice.and_return(@add_to_cart_doc/'cart/cartitems/cartitem'.inject([]) {|a, i| a << i})
      aws_options = {:asin => '0679775439', 
        :aws_cart_id => session[:cart][:cart_id], 
        :hmac => session[:cart][:hmac]}
      controller.should_receive(:aws_add_to_cart).with(aws_options).once.and_return(aws_response)
      
      get :add, :asin => '0679775439'
      
      session[:cart].should == {:cart_id => '104-9487830-8806330', :hmac => 'Ze%2B9VNGLN3MRlgl2go%2FxH8aoiMY%3D'}
      assigns[:cart].should_not be_nil
      assigns[:cart].class.should == CartPresenter
      assigns[:cart].items.length.should == 3      
    end
    
    it 'should redirect to / if there is no ASIN in the params' do
      session[:cart] = {:cart_id => '104-9487830-8806330', :hmac => 'Ze%2B9VNGLN3MRlgl2go%2FxH8aoiMY%3D'}        

      get :add
      
      response.should redirect_to('/')
    end
    
    it 'should nil out the cart and redirect to / if the cart is not valid' do
      session[:cart] = {:cart_id => 'foo', :hmac => 'bar'}
      aws_response = mock('bad_cart_aws_response')
      aws_response.should_receive(:doc).and_return(@bad_cart_doc)
      aws_response.should_receive(:cart_items).and_return(nil)
      aws_options = {:asin => '0679775439', 
        :aws_cart_id => session[:cart][:cart_id], 
        :hmac => session[:cart][:hmac]}
      controller.should_receive(:aws_add_to_cart).with(aws_options).once.and_return(aws_response)
      
      get :add, :asin => '0679775439',
        :aws_cart_id => 'foo',
        :hmac => 'bar'
      
      assigns[:cart].should_not be_valid
      response.should redirect_to('/')
      session[:cart].should be_nil
    end
    
  end

  describe '#update' do
    
    before :all do
      @modify_cart_doc = Hpricot.parse(File.open('spec/response_xml/cart_modify_cart_B.xml', 'r'))      
    end
    
    it 'should update the quantity of an existing cart item in a cart' do
      session[:cart] = {:cart_id => '104-9487830-8806330', :hmac => 'Ze%2B9VNGLN3MRlgl2go%2FxH8aoiMY%3D'}        
      aws_response = mock('modify_cart_aws_response')
      aws_response.should_receive(:doc).and_return(@modify_cart_doc)
      aws_response.should_receive(:cart_items).twice.and_return(@modify_cart_doc/'cart/cartitems/cartitem'.inject([]) {|a, i| a << i})
      aws_options = {:cart_item_id => 'U2B36R1SQQ0LPY',
        :quantity => '0',
        :aws_cart_id => session[:cart][:cart_id], 
        :hmac => session[:cart][:hmac]}
      controller.should_receive(:aws_modify_cart).with(aws_options).once.and_return(aws_response)

      get :update, :cart_item_id => 'U2B36R1SQQ0LPY', :quantity => '0'
      
      session[:cart].should == {:cart_id => '104-9487830-8806330', :hmac => 'Ze%2B9VNGLN3MRlgl2go%2FxH8aoiMY%3D'}
      assigns[:cart].should_not be_nil
      assigns[:cart].class.should == CartPresenter
      assigns[:cart].items.length.should == 3      
    end
    
    it 'should redirect to / if the params are not valid (no cart item and/or quantity)'
    it 'should nil out the cart and redirect to / if the cart is not complete'
    it 'should nil out the cart and redirect to / if the cart is not valid'

  end

  describe '#clear' do
    
    before :all do
      @clear_cart_doc = Hpricot.parse(File.open('spec/response_xml/cart_clear_cart_B.xml', 'r'))
    end
    
    it 'should clear an existing cart at Amazon.com' do 
      session[:cart] = {:cart_id => '104-9487830-8806330', :hmac => 'Ze%2B9VNGLN3MRlgl2go%2FxH8aoiMY%3D'}        
      aws_response = mock('clear_cart_aws_response')
      aws_response.should_receive(:doc).and_return(@clear_cart_doc)
      aws_response.should_receive(:cart_items).twice.and_return(@clear_cart_doc/'cart/cartitems/cartitem'.inject([]) {|a, i| a << i})
      aws_options = {:aws_cart_id => session[:cart][:cart_id], 
        :hmac => session[:cart][:hmac]}
      controller.should_receive(:aws_clear_cart).with(aws_options).once.and_return(aws_response)

      get :clear
      
      session[:cart].should be_nil
      response.should redirect_to('/')
    end    
  end
  
  describe '#show' do
    before :all do
      @get_cart_doc = Hpricot.parse(File.open('spec/response_xml/cart_get_cart_B.xml'))
      @bad_cart_doc = Hpricot.parse(File.open('spec/response_xml/cart_get_cart_bad_cart.xml'))
    end
    
    it 'should get a cart' do
      session[:cart] = {:cart_id => '104-9487830-8806330', :hmac => 'Ze%2B9VNGLN3MRlgl2go%2FxH8aoiMY%3D'}        
      aws_response = mock('get_cart_aws_response')
      aws_response.should_receive(:doc).and_return(@get_cart_doc)
      aws_response.should_receive(:cart_items).twice.and_return(@get_cart_doc/'cart/cartitems/cartitem'.inject([]) {|a, i| a << i})
      aws_options = {:aws_cart_id => session[:cart][:cart_id], 
        :hmac => session[:cart][:hmac]}
      controller.should_receive(:aws_get_cart).with(aws_options).once.and_return(aws_response)

      get :show
      
      assigns[:cart].should be_valid
    end
    
    it 'should redirect to / if the cart is invalid' do
      session[:cart] = {:cart_id => 'foo', :hmac => 'bar'}
      aws_response = mock('get_cart_aws_response')
      aws_response.should_receive(:doc).and_return(@bad_cart_doc)
      aws_response.should_receive(:cart_items).twice.and_return(@bad_cart_doc/'cart/cartitems/cartitem'.inject([]) {|a, i| a << i})
      aws_options = {:aws_cart_id => session[:cart][:cart_id], 
        :hmac => session[:cart][:hmac]}
      controller.should_receive(:aws_get_cart).with(aws_options).once.and_return(aws_response)

      get :show
      
      assigns[:cart].should_not be_valid
      response.should redirect_to('/')
    end
  end
  
end