require 'htmlentities'

class ItemPresenter < AwsPresenter
  
  attr_from_xml :asin, '//asin'
  attr_from_xml :aspect_ratio, '/itemattributes/aspectratio'
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
  
  attr_array_from_xml :actors
  attr_array_from_xml :artists
  attr_array_from_xml :authors
  attr_array_from_xml :directors
  attr_array_from_xml :formats
   
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

  def prices
    @prices ||= []
    if @prices.empty?
      return @prices if amazon_price.nil?

      ap = OpenStruct.new(:price_type => 'amazon', :amount => amazon_price[:formatted])
      lp = OpenStruct.new(:price_type => 'list', :amount => list_price[:formatted]) unless list_price.nil?

      if lp.nil?
        @prices << ap
      elsif amazon_price[:amount] < list_price[:amount]
        @prices << lp
        @prices << ap
      else
        @prices << lp
      end

    end
    @prices
  end

  def rank_group
    case self.product_group
      when 'Book' then 'Books'
      when 'DVD'  then 'Movies & TV'
      else self.product_group
    end
  end
  
  def summary_partial
    "#{product_group.downcase}_summary"
  end
  
  def other_details_partial
    "#{product_group.downcase}_other_details"
  end
  
  def to_param
    asin
  end
  
end