require File.dirname(__FILE__) + '/../spec_helper'

describe ItemController do

  it 'should route to /item/123456' do 
    route_for(:controller => 'item', 
              :action => 'index',
              :asin => '123456').should == '/item/123456'
  end

  it 'should get routed from /item/123456' do
    params_from(:get, '/item/123456').should == {:controller => 'item',
                                                 :action => 'index',
                                                 :asin => '123456'}
  end

  it 'should call Amazon with an ItemLookup properly when an asin is requested' do
    controller.should_receive(:ecs_item_lookup).with(:asin => '123456').and_return('foo')
    
    get 'index', :asin => '123456'
    
    assigns[:item].should == 'foo'
  end
  
end