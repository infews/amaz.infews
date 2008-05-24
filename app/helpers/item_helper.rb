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
      bestsellers_path(results.search_index, page)
    else
      search_path(results.search_index, results.keywords, page)
    end
  end
  
end