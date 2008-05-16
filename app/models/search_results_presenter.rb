class SearchResultsPresenter < AwsItemPresenter
  
  attr_reader :doc
  attr_reader :items
  
  attr_from_xml :total_pages, '//items/totalpages'
  attr_from_xml :total_results, '//items/totalresults'
  attr_from_xml :search_index, '//items/request/itemsearchrequest/searchindex'
  attr_from_xml :keywords, '//items/request/itemsearchrequest/keywords'  
  
  def initialize(response)
    @doc = response.doc
    @items = response.items.collect {|i| ItemPresenter.new(i)}    
  end
  
  def page
    @page = (@xml_item_page ||= get('//items/request/itemsearchrequest/itempage')) || '1'
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
     
end