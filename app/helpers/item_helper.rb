module ItemHelper

  def previous_page_of(results)
    other_page_of_results(results, results.page.to_i - 1)
  end
  
  def next_page_of(results)
    other_page_of_results(results, results.page.to_i + 1)
  end
  
  private
  
  def other_page_of_results(results, page)
    if results.bestseller_search?
      bestsellers_path(:search_index => results.search_index, 
                       :page => page)
    else
      search_path(:search_index => results.search_index, 
                  :keywords => results.keywords, 
                  :bestseller => results.bestseller_search?,
                  :page => page)
    end    
  end
  
end