require 'htmlentities'

class ItemPresenter < AwsItemPresenter
  
  attr_reader :doc
  
  attr_from_xml :asin, '//asin'
  attr_from_xml :audience_rating, '/itemattributes/audiencerating'  
  attr_from_xml :binding, '/itemattributes/binding'
  attr_from_xml :detail_page_url, '/detailpageurl'
  attr_from_xml :edition, '/itemattributes/edition'
  attr_from_xml :label, '/itemattributes/label'
  attr_from_xml :number_of_reviews, '/customerreviews/totalreviews'  
  attr_from_xml :product_group, '/itemattributes/productgroup'
  attr_from_xml :sales_rank, '/salesrank'
  attr_from_xml :studio, '/itemattributes/studio'
  attr_from_xml :title, '/itemattributes/title'
  
  attr_array_from_xml :actors, '//itemattributes', 'actor'
  attr_array_from_xml :artists, '//itemattributes', 'artist'
  attr_array_from_xml :authors, '//itemattributes', 'author'
  attr_array_from_xml :directors, '//itemattributes', 'director'  
  attr_array_from_xml :formats, '//itemattributes', 'format'  
   
  def initialize(doc)
    @doc = doc
    @coder = HTMLEntities.new
  end
  
  def amazon_price
    # TODO: better protect against no amazon? offer?    
    @amazon_price ||= get_price '//offers/offer/offerlisting/price'
  end

  def average_rating
    @xml_rating ||= get '//customerreviews/averagerating'
    @average_rating = @xml_rating.nil? ? "No Customer Ratings" : "#{@xml_rating} out of 5 stars"
  end

  def editorial_reviews
    @review_nodes ||= (@doc%:editorialreviews).children_of_type('editorialreview')

    @editorial_reviews ||= @review_nodes.inject([]) do |reviews, this_review|
                             reviews << {:source => (this_review%:source).innerHTML,
                                         :content => @coder.decode((this_review%:content).innerHTML)}
                           end
  rescue
    nil
  end
  
  def image
    @image_node ||= @doc%'//mediumimage' || @doc%'//smallimage'
    
    @image ||= {:url    => (@image_node%'url').innerHTML,
                :height => (@image_node%'height').innerHTML,
                :width  => (@image_node%'width').innerHTML}
  rescue
    nil
  end

  def list_price    
    @list_price ||= get_price '//itemattributes/listprice'
  end
    
  def tracks
    @tracks ||= (@doc%'tracks').children_of_type('disc').inject([]) do |discs, disc_node|
                  discs << disc_node.children_of_type('track').inject([]) do |tracks, track_node| 
                             tracks << track_node.innerHTML
                           end
                end
  rescue
    nil
  end
  
  private
  
  def get_price(xpath)
    doc_node = @doc%xpath
    return nil if doc_node.nil?
    
    {:amount    => (doc_node/'amount').innerHTML.to_i,
     :formatted => (doc_node/'/formattedprice').innerHTML}
  end
    
end