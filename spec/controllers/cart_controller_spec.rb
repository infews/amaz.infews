require File.dirname(__FILE__) + '/../spec_helper'

describe CartController do
  
  describe '#add' do    
  
    describe 'happy path' do
      it 'should create a new cart with this item if one does not exist in the session' do
        session[:cart] = nil            
        controller.should_receive(:aws_create_cart).with({:asin => '0143112562'}).once.and_return('aws_response')
        cart = mock('cart_presenter', {:errors => nil,
                                       :cart_id => 'foo',
                                       :url_encoded_hmac  => 'bar'})
        CartPresenter.stub!(:new).and_return(cart)

        get :add, :asin => '0143112562'            
        response.should render_template('show')
      end

      it 'should initialize a CartPresenter from the Amazon aws_response' do
        session[:cart] = nil      
        controller.stub!(:aws_create_cart).with({:asin => '0143112562'}).once.and_return('aws_response')
        cart = mock('cart_presenter', {:errors => nil,
                                       :cart_id => 'foo',
                                       :url_encoded_hmac  => 'bar'})
        CartPresenter.should_receive(:new).and_return(cart)

        get :add, :asin => '0143112562'      
        response.should render_template('show')
      end

      it 'should store a new cart in the session if one was created' do
        session[:cart] = nil      
        controller.stub!(:aws_create_cart).with({:asin => '0143112562'}).once.and_return('aws_response')
        cart = mock('cart_presenter', {:errors => nil,
                                       :cart_id => '102-3956189-4078545',
                                       :url_encoded_hmac  => '102-3956189-4078545'})
        CartPresenter.stub!(:new).and_return(cart)

        get :add, :asin => '0143112562'      

        session[:cart].should == {:cart_id => '102-3956189-4078545', :hmac => '102-3956189-4078545'}        
        response.should render_template('show')
      end

      it 'should add a new cart item to an existing cart' do
        session[:cart] = {:cart_id => '104-9487830-8806330', :hmac => 'Ze%2B9VNGLN3MRlgl2go%2FxH8aoiMY%3D'}        
        aws_options = {:asin => '0679775439', 
                       :cart_id => session[:cart][:cart_id], 
                       :hmac => session[:cart][:hmac]}
        controller.should_receive(:aws_add_to_cart).with(aws_options).once.and_return('aws_response')
        cart = mock('cart_presenter', {:errors => nil,
                                       :cart_id => '104-9487830-8806330',
                                       :url_encoded_hmac  => 'Ze%2B9VNGLN3MRlgl2go%2FxH8aoiMY%3D'})
        CartPresenter.stub!(:new).and_return(cart)

        get :add, :asin => '0679775439'

        session[:cart].should == {:cart_id => '104-9487830-8806330', :hmac => 'Ze%2B9VNGLN3MRlgl2go%2FxH8aoiMY%3D'}
        assigns[:cart].should_not be_nil
        response.should render_template('show')
      end
    end
    
    describe 'error paths' do
      it 'should redirect to / if there is no ASIN in the params' do
        session[:cart] = {:cart_id => '104-9487830-8806330', :hmac => 'Ze%2B9VNGLN3MRlgl2go%2FxH8aoiMY%3D'}        

        get :add

        response.should redirect_to('/')
      end

      it 'should nil out the cart and redirect to / if the cart ID is not valid' do
        session[:cart] = {:cart_id => 'foo', :hmac => 'bar'}
        params[:asin] = '123456'
        aws_options = {:asin => params[:asin], 
                       :cart_id => session[:cart][:cart_id], 
                       :hmac => session[:cart][:hmac]}
        controller.should_receive(:aws_add_to_cart).with(aws_options).once.and_return('aws_response')
        cart = mock('cart_presenter', :errors => {:code => 'AWS.ECommerceService.InvalidCartId', 
                                                  :message => 'bar'})
        CartPresenter.stub!(:new).and_return(cart)

        get :add, :asin => params[:asin],
                  :cart_id => session[:cart][:cart_id],
                  :hmac => session[:cart][:hmac]

        flash[:error].should == 'This cart does not exist at Amazon.com.'
        response.should redirect_to('/')
        session[:cart].should be_nil
      end

      it 'should nil out the cart and redirect to / if the HMAC is not valid' do
        session[:cart] = {:cart_id => 'foo', :hmac => 'bar'}
        params[:asin] = '123456'
        aws_options = {:asin => params[:asin], 
                       :cart_id => session[:cart][:cart_id], 
                       :hmac => session[:cart][:hmac]}
        controller.should_receive(:aws_add_to_cart).with(aws_options).once.and_return('aws_response')
        cart = mock('cart_presenter', {:errors => {:code => 'AWS.ECommerceService.InvalidHMAC',
                                                   :message => 'bar'},
                                      :cart_id => 'foo',
                                      :url_encoded_hmac => 'bar'})
        CartPresenter.stub!(:new).and_return(cart)

        get :add, :asin => params[:asin],
                  :cart_id => session[:cart][:cart_id],
                  :hmac => session[:cart][:hmac]

        flash[:error].should == 'This cart does not exist at Amazon.com.'
        response.should redirect_to('/')
        session[:cart].should be_nil
      end

      it 'should redirect back to referring page with a useful message on an AWS.InternalError' do
        session[:cart] = nil
        params[:asin] = 'foo'      
        controller.should_receive(:aws_create_cart).with(:asin => params[:asin]).once.and_return('aws_response')      
        cart = mock('cart_presenter', {:errors => {:code => 'AWS.InternalError',
                                                   :message => 'bar'},
                                      :cart_id => 'foo',
                                      :url_encoded_hmac => 'bar'})
        CartPresenter.stub!(:new).and_return(cart)

        get :add, :asin => params[:asin]

        flash[:info].should == 'There was an error at Amazon.com. Please try again later.'
        response.should redirect_to('/')
      end

      it 'should provide a useful message on an AWS.ECommerceService.ItemAlreadyInCart error' do
        session[:cart] = {:cart_id => 'foo', :hmac => 'bar'}
        params[:asin] = '123456'
        aws_options = {:asin => params[:asin], 
                       :cart_id => session[:cart][:cart_id], 
                       :hmac => session[:cart][:hmac]}
        controller.should_receive(:aws_add_to_cart).with(aws_options).once.and_return('aws_response')
        cart = mock('cart_presenter', {:errors => {:code => 'AWS.ECommerceService.ItemAlreadyInCart',
                                                   :message => 'bar'},
                                      :cart_id => session[:cart][:cart_id],
                                      :url_encoded_hmac => session[:cart][:hmac]})
        CartPresenter.stub!(:new).and_return(cart)

        get :add, :asin => params[:asin],
                  :cart_id => session[:cart][:cart_id],
                  :hmac => session[:cart][:hmac]

        flash[:info].should == 'This item is already in your cart.'
        session[:cart].should == {:cart_id => 'foo', :hmac => 'bar'}
        assigns[:cart].should_not be_nil
      end

      # (likely) random param errors
      it 'should redirect to / with an invalid param message on an AWS.InvalidParameterValue' do
        session[:cart] = {:cart_id => 'foo', :hmac => 'bar'}
        params[:asin] = '123456'
        aws_options = {:asin => params[:asin], 
                       :cart_id => session[:cart][:cart_id], 
                       :hmac => session[:cart][:hmac]}
        controller.should_receive(:aws_add_to_cart).with(aws_options).once.and_return('aws_response')
        cart = mock('cart_presenter', {:errors => {:code => 'AWS.InvalidParameterValue',
                                                   :message => 'bar'},
                                      :cart_id => session[:cart][:cart_id],
                                      :url_encoded_hmac => session[:cart][:hmac]})
        CartPresenter.stub!(:new).and_return(cart)

        get :add, :asin => params[:asin],
                  :cart_id => session[:cart][:cart_id],
                  :hmac => session[:cart][:hmac]

        flash[:error].should == 'There was an error with your request.'
        session[:cart].should == {:cart_id => 'foo', :hmac => 'bar'}
        assigns[:cart].should_not be_nil
        response.should redirect_to('/')
      end

      it 'should redirect back to referring page with a useful message on an AWS.ECommerceService.ItemNotEligibleForCart' do
        session[:cart] = {:cart_id => 'foo', :hmac => 'bar'}
        params[:asin] = '123456'
        aws_options = {:asin => params[:asin], 
                       :cart_id => session[:cart][:cart_id], 
                       :hmac => session[:cart][:hmac]}
        controller.should_receive(:aws_add_to_cart).with(aws_options).once.and_return('aws_response')
        cart = mock('cart_presenter', {:errors => {:code => 'AWS.ECommerceService.ItemNotEligibleForCart',
                                                   :message => 'bar'},
                                      :cart_id => session[:cart][:cart_id],
                                      :url_encoded_hmac => session[:cart][:hmac]})
        CartPresenter.stub!(:new).and_return(cart)

        get :add, :asin => params[:asin],
                  :cart_id => session[:cart][:cart_id],
                  :hmac => session[:cart][:hmac]

        flash[:error].should == 'This item is not eligible for this cart.'
        session[:cart].should == {:cart_id => 'foo', :hmac => 'bar'}
        assigns[:cart].should_not be_nil
        # TODO: response.should redirect_to(:back)
      end
      
      # dunno
      it 'should redirect back to referring page with a useful message on any other error' do
        session[:cart] = {:cart_id => 'foo', :hmac => 'bar'}
        params[:asin] = '123456'
        aws_options = {:asin => params[:asin], 
                       :cart_id => session[:cart][:cart_id], 
                       :hmac => session[:cart][:hmac]}
        controller.should_receive(:aws_add_to_cart).with(aws_options).once.and_return('aws_response')
        cart = mock('cart_presenter', {:errors => {:code => 'foo_diddy',
                                                   :message => 'bar'},
                                      :cart_id => session[:cart][:cart_id],
                                      :url_encoded_hmac => session[:cart][:hmac]})
        CartPresenter.stub!(:new).and_return(cart)

        get :add, :asin => params[:asin],
                  :cart_id => session[:cart][:cart_id],
                  :hmac => session[:cart][:hmac]

        flash[:error].should == 'Whoops! There was an unknown error.'
        session[:cart].should == {:cart_id => 'foo', :hmac => 'bar'}        
        # TODO: response.should redirect_to(:back)
      end
    end
  end

  describe '#update' do
    
    it 'should update the quantity of an existing cart item in a cart' do
      session[:cart] = {:cart_id => '104-9487830-8806330', :hmac => 'Ze%2B9VNGLN3MRlgl2go%2FxH8aoiMY%3D'}        
      aws_options = {:cart_item_id => 'U2B36R1SQQ0LPY',
                     :quantity => '2',
                     :cart_id => session[:cart][:cart_id], 
                     :hmac => session[:cart][:hmac]}
      controller.should_receive(:aws_modify_cart).with(aws_options).once.and_return('aws_response')
      cart = mock('cart_presenter', {:errors => nil,
                                     :items => 'items',
                                     :cart_id => session[:cart][:cart_id],
                                     :url_encoded_hmac => session[:cart][:hmac]})
      
      CartPresenter.stub!(:new).and_return(cart)
      
      get :update, :cart_item_id => 'U2B36R1SQQ0LPY', :quantity => '2'
      
      session[:cart].should == {:cart_id => '104-9487830-8806330', :hmac => 'Ze%2B9VNGLN3MRlgl2go%2FxH8aoiMY%3D'}
      assigns[:cart].should_not be_nil
      response.should render_template('show')
    end

    it 'should redirect to / if the last item was removed from the cart' do
      session[:cart] = {:cart_id => '104-9487830-8806330', :hmac => 'Ze%2B9VNGLN3MRlgl2go%2FxH8aoiMY%3D'}        
      aws_options = {:cart_item_id => 'U2B36R1SQQ0LPY',
                     :quantity => '0',
                     :cart_id => session[:cart][:cart_id], 
                     :hmac => session[:cart][:hmac]}
      controller.should_receive(:aws_modify_cart).with(aws_options).once.and_return('aws_response')
      cart = mock('cart_presenter', {:errors => nil,
                                     :items => [],
                                     :cart_id => session[:cart][:cart_id],
                                     :url_encoded_hmac => session[:cart][:hmac]})
      
      CartPresenter.stub!(:new).and_return(cart)

      get :update, :cart_item_id => 'U2B36R1SQQ0LPY', :quantity => '0'
      
      response.should redirect_to(:action => 'clear')
    end
    
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
      aws_options = {:cart_id => session[:cart][:cart_id], 
        :hmac => session[:cart][:hmac]}
      controller.should_receive(:aws_clear_cart).with(aws_options).once.and_return(aws_response)

      get :clear
      
      session[:cart].should be_nil
      response.should redirect_to('/')
    end    
  end
  
  describe '#show' do
    # TODO: mock these out
    before :all do
      @get_cart_doc = Hpricot.parse(File.open('spec/response_xml/cart_get_cart_B.xml'))
      @bad_cart_doc = Hpricot.parse(File.open('spec/response_xml/cart_get_cart_bad_cart.xml'))
    end
    
    it 'should get a cart' do
      session[:cart] = {:cart_id => '104-9487830-8806330', :hmac => 'Ze%2B9VNGLN3MRlgl2go%2FxH8aoiMY%3D'}        
      aws_response = mock('get_cart_aws_response')
      aws_response.should_receive(:doc).and_return(@get_cart_doc)
      aws_response.should_receive(:cart_items).twice.and_return(@get_cart_doc/'cart/cartitems/cartitem'.inject([]) {|a, i| a << i})
      aws_options = {:cart_id => session[:cart][:cart_id], 
        :hmac => session[:cart][:hmac]}
      controller.should_receive(:aws_get_cart).with(aws_options).once.and_return(aws_response)

      get :show
      
      assigns[:cart].errors.should be_nil
    end
    
    it 'should redirect to / if the cart has errors' do
      session[:cart] = {:cart_id => 'foo', :hmac => 'bar'}
      aws_response = mock('get_cart_aws_response')
      aws_response.should_receive(:doc).and_return(@bad_cart_doc)
      aws_response.should_receive(:cart_items).twice.and_return(@bad_cart_doc/'cart/cartitems/cartitem'.inject([]) {|a, i| a << i})
      aws_options = {:cart_id => session[:cart][:cart_id], 
        :hmac => session[:cart][:hmac]}
      controller.should_receive(:aws_get_cart).with(aws_options).once.and_return(aws_response)

      get :show
      
      response.should redirect_to('/')
    end
  end
  
end