class SearchResultsPresenter < AwsPresenter
  include ActionView::Helpers::NumberHelper # included for number_with_delimiter  
  
  attr_reader :doc
  attr_reader :items
  
  attr_from_xml :browse_node, '//items/request/itemsearchrequest/browsenode'
  attr_from_xml :keywords, '//items/request/itemsearchrequest/keywords'  
  attr_from_xml :search_index, '//items/request/itemsearchrequest/searchindex'
  attr_from_xml :total_pages, '//items/totalpages'
  attr_from_xml :total_results, '//items/totalresults'
  
  def initialize(response)
    @doc = response.doc
    @items = response.items.collect {|i| ItemPresenter.new(i)}    
  end
  
  def bestseller_search?
    return true if self.search_index == 'Books' && self.browse_node == '1000'
    
    false
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
    @message = 'Current Bestsellers in Books' if bestseller_search?
    @message ||= "Searching #{get('//items/request/itemsearchrequest/searchindex')} for \"#{get('//items/request/itemsearchrequest/keywords')}\""
  end

  def page_info
    @page_info ||= "page #{page} of #{number_with_delimiter(total_pages)}"
  end
     
end