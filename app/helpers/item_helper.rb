module ItemHelper

  def previous_page_of(results)
    search_path(:search_index => results.search_index, :keywords => results.keywords, :page => (results.page.to_i - 1))
  end
  
  def next_page_of(results)
    search_path(:search_index => results.search_index, :keywords => results.keywords, :page => (results.page.to_i + 1))
  end    
  
end