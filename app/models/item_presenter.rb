class ItemPresenter
  attr_reader :doc
  
  def initialize(doc)
    @doc = doc
  end
  
  def amazon_price
    # TODO: better protect against no amazon? offer?    
    @amazon_price ||= get_price '//offers/offer/offerlisting/price'
  end
  
  def asin
    @asin ||= get '//asin'
  end
  
  def authors
    @authors_node ||= @doc/'//itemattributes/author'
    return nil if @authors_node.empty?
    
    @authors ||= @authors_node.inject([]) do |authors, author_node|
                   authors << author_node.innerHTML
                 end
  end
  
  def average_rating
    @average_rating ||= get '//customerreviews/averagerating'
  end
  
  def description
    # TODO: this will need to expand to an array as we support other types of
    # =>    'descriptions', Amazon's review, publisher's info, etc.
    @description_node ||= @doc/'//editorialreviews/editorialreview'

    if (@description_node%'source').innerHTML != 'Product Description'
      return nil
    end
   
    @description ||= {:source  => (@description_node%'source').innerHTML,
                      :content => (@description_node%'content').innerHTML}
  end
  
  def image
    @image_node ||= @doc%'//mediumimage' || @doc%'//smallimage'
    return nil if @image_node.nil?
    
    @image ||= {:url    => (@image_node%'url').innerHTML,
                :height => (@image_node%'height').innerHTML,
                :width  => (@image_node%'width').innerHTML}
  end
  
  def list_price    
    @list_price ||= get_price '//itemattributes/listprice'
  end
  
  def number_of_reviews
    @number_of_reviews ||= get '//customerreviews/totalreviews'  
  end
  
  def sales_rank
    @sales_rank ||= get '//salesrank'
  end
  
  def title
    @title ||= get '//itemattributes/title'
  end
  
  private
  
  def get(xpath)
    node = @doc%xpath
    node.nil? ? nil : node.innerHTML
  end
  
  def get_price(xpath)
    doc_node = @doc%xpath
    return nil if doc_node.nil?
    
    {:amount    => (doc_node/'amount').innerHTML.to_i,
     :formatted => (doc_node/'/formattedprice').innerHTML}
  end
    
end