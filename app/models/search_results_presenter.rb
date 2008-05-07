class SearchResultsPresenter < AwsItemPresenter
  
  attr_reader :doc
  attr_reader :items
  
  def initialize(response)
    @doc = response.doc
    @items = response.items.collect {|i| ItemPresenter.new(i)}    
  end
  
  def page
    @page ||= get('//items/request/itemsearchrequest/itempage')
  end
  
  def total_pages
    @total_pages ||= get('items/totalpages')
  end

  def total_results
    @total_results ||= get('items/totalresults')
  end
  
  def first_page?
    @first_page ||= (page == '1')
  end
  
  def last_page?
    @last_page ||= (page == total_pages)
  end
  
  def message
    @message ||= "Searching #{get('//items/request/itemsearchrequest/searchindex')} for \"#{get('//items/request/itemsearchrequest/keywords')}\""
  end

  def page_info
    @page_info ||= "page #{page} of #{total_pages}"
  end
   
  def search_index
    @search_index ||= get('//items/request/itemsearchrequest/searchindex')
  end

  def keywords
    @keywords ||= get('//items/request/itemsearchrequest/keywords')
  end
  
end