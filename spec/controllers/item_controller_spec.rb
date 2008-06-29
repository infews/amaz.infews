require File.dirname(__FILE__) + '/../spec_helper'

# TODO: stub out the calls to the library instead of stubbing out fetch

describe ItemController do

  describe '#show' do

    it 'should call Amazon with an ItemLookup properly when an asin is requested and instantiate an ItemPresenter' do
      item = mock('item_presenter', {:asin => '0143112562'})
      ItemPresenter.stub!(:new).and_return(item)
      aws_response = mock('aws_response', {:items => [item], :errors => nil})
      controller.should_receive(:aws_item_lookup).with({:asin => '0143112562'}).once.and_return(aws_response)

      get 'show', :asin => '0143112562'

      assigns[:item].asin.should == '0143112562'
    end
  
    it 'should redirect to "/" & tell the user when that item does not exist' do
      aws_response = mock('aws_response', {:errors => {:code => 'AWS.InvalidParameterValue', :message => ''}})
      controller.should_receive(:aws_item_lookup).with({:asin => 'fffffffff'}).once.and_return(aws_response)

      get 'show', :asin => 'fffffffff'

      assigns[:item].should be_nil
      response.should redirect_to('/')
      # TODO: Flash should be something
    end
    
  end
  
  describe '#search' do

    it 'should call Amazon with a book keyword search' do
      search_options = {:keywords => 'Against the Day',
                        :page => '1',
                        :search_index => 'Books'}
      controller.should_receive(:aws_item_search).with(search_options).once.and_return('aws_response')
      items = mock('item_presenters_array', :size => 4)
      search = mock('search_results_presenter', {:items => items})
      SearchResultsPresenter.stub!(:new).and_return(search)

      get 'search', :search_index => 'Books', 
                    :keywords => 'Against the Day', 
                    :page => '1'

      assigns[:results].should_not be_nil   
      assigns[:results].items.size.should == 4
    end
  
    it 'should support searching to an arbitrary page of search results' do
      search_options = {:search_index => 'Books', 
                        :keywords => 'harry potter', 
                        :page => '178'}
      controller.should_receive(:aws_item_search).with(search_options).once.and_return('aws_response')
      items = mock('item_presenters_array', :size => 1)
      search = mock('search_results_presenter', {:items => items})
      SearchResultsPresenter.stub!(:new).and_return(search)

      get 'search', :search_index => 'Books', 
                    :keywords => 'harry potter', 
                    :page => '178'

      assigns[:results].should_not be_nil   
      assigns[:results].items.size.should == 1    
    end

    it 'should preserve the state of the previous seach' do
      search_options = {:keywords => 'Against the Day',
                        :page => '1',
                        :search_index => 'Books'}
      controller.should_receive(:aws_item_search).with(search_options).once.and_return('aws_response')
      items = mock('item_presenters_array', :size => 4)
      search = mock('search_results_presenter', {:items => items})
      SearchResultsPresenter.stub!(:new).and_return(search)

      get 'search', :search_index => 'Books', 
                    :keywords => 'Against the Day', 
                    :page => '1'

      assigns[:previous_keywords].should == 'Against the Day'
      assigns[:previous_search_index].should == 'Books'    
    end

    it 'should support a search for book bestsellers' do
      search_options = {:page => '1',
                        :browse_node => '1000',
                        :sort => 'salesrank',
                        :search_index => 'Books'}
      controller.should_receive(:aws_item_search).with(search_options).once.and_return('aws_response')
      items = mock('item_presenters_array', :size => 4)
      search = mock('search_results_presenter', {:items => items})
      SearchResultsPresenter.stub!(:new).and_return(search)

      get 'search', :search_index => 'Books', 
                    :bestsellers => 'true'
      assigns[:previous_search_index].should == 'Books'    
    end

    it 'should redirect to an empty search page when an item is not found' do
      aws_response = mock('aws_response__no_search_results', 
                          :errors => {:code => 'AWS.ECommerceService.NoExactMatches',
                                      :message => 'foo'})
      search_options = {:search_index => 'Books', 
                        :keywords => 'parry hotter', 
                        :page => '1'}
      controller.should_receive(:aws_item_search).with(search_options).once.and_return(aws_response)
      search = mock('search_results_presenter', {:items => nil})
      SearchResultsPresenter.stub!(:new).and_return(search)

      get 'search', :search_index => 'Books', 
                    :keywords => 'parry hotter', 
                    :page => '1'

      # TODO: test flash
      assigns[:results].items.should be_nil      
    end

  end

end  