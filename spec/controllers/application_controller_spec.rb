require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController, 'routing' do

  it 'should route to /item/show/123456' do 
    route_for(:controller => 'item', 
              :action => 'show',
              :asin => '123456').should == '/item/show/123456'
  end

  it 'should get routed from /item/123456' do
    params_from(:get, '/item/show/123456X').should == {:controller => 'item',
                                                       :action     => 'show',
                                                       :asin       => '123456X'}
  end

  it "should route to /item/search?search_type=book&keywords=foo" do 
    route_for(:controller => 'item', 
              :action => 'search',
              :search_index => 'Books',
              :keywords => 'foo').should == '/item/search/Books/foo'
  end

  it 'should get routed from /item/search?keywords=foo&search=book' do
    params_from(:post, "/item/search/Books/J%20K%20Rowling").should == {:controller => 'item', 
                                                            :action => 'search',
                                                            :search_index => 'Books',
                                                            :keywords => 'J K Rowling',
                                                            :page => '1'}
  end

  it "should route to /item/search/Books/foo%20bar/3" do 
    route_for(:controller => 'item', 
              :action => 'search',
              :search_index => 'Books',
              :keywords => 'foo bar',
              :page => '3').should == '/item/search/Books/foo%20bar/3'
  end

  it 'should get routed from /item/search/Books/foo%20bar/3' do
    params_from(:post, '/item/search/Books/foo%20bar/3').should == {:controller => 'item', 
                                                                    :action => 'search',
                                                                    :search_index => 'Books',
                                                                    :keywords => 'foo bar',
                                                                    :page => '3'}
  end

  it 'should get routed from /item/search/=foo&search=book&page=3' do
    params_from(:post, '/item/search/Books/foo/3').should == {:controller => 'item', 
                                                              :action => 'search',
                                                              :search_index => 'Books',
                                                              :keywords => 'foo',
                                                              :page => '3'}
  end
  
  
  it 'should get routed to a book bestseller search' do
    params_from(:get,'/item/bestsellers/Books/1').should == {:controller => 'item',
                                                             :action => 'search',
                                                             :search_index => 'Books',
                                                             :bestsellers => 'true',
                                                             :page => '1'}
  end


  it 'should route / to the book bestsellers page' do
    params_from(:get, '/').should == {:controller => 'item',
                                      :action => 'search',
                                      :search_index => 'Books',
                                      :bestsellers => 'true'}
  end
  
end