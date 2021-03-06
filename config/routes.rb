ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"
  # TODO: there's got to be a better way to do these tests (mostly used when no connectivity)
  map.connect 'item_test',   :controller => 'item', :action => 'test_show'
  map.connect 'search_test', :controller => 'item', :action => 'test_search'
  
  
  map.with_options :controller => 'item' do |item|
    item.show 'item/show/:asin', :action => 'show'
    
    item.bestsellers 'item/bestsellers/:search_index/:page', :action => 'search', 
                                                             :bestsellers => 'true'
                                                           
    item.search 'item/search/:search_index/:keywords/:page', :action => 'search',
                                                             :defaults => {:page => '1'},
                                                             :keywords => /[^\/\?]*/
  end
  
  map.with_options :controller => 'cart' do |cart|
    cart.cart_clear 'cart/clear', :action => 'clear'
    cart.cart 'cart', :action => 'show'
    cart.cart_add 'cart/add/:asin', :action => 'add'
    cart.cart_update 'cart/update/:cart_item_id/:quantity', :action => 'update'
  end
  
  # TODO: is there a way to shortcut this, pointing to the same-ish route above?
  map.home '/', :controller => 'item', :action => 'search', :search_index => 'Books', :bestsellers => 'true'
  
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
