require 'date'
require 'iconv'
require 'net/http'
require 'uri'

# The main module to be mixed in to your application/calling class.  On include,
# your class will gain an reader <tt>ecs</tt> that can be used to call the 
# Amazon REST API.
module AmazonAWS

  def aws_request
    @aws_request ||= Request.new(amazon_associates_id, amazon_access_key)
  end
    
  protected

  # Request wraps all calls to the AmazonAWS API.  Make calls through your class's <tt>ecs</tt>
  # attribute reader.
  class Request
    def initialize(amazon_associates_id, amazon_access_key)
      @url_base = "#{AWS_URL}&AWSAccessKeyId=#{amazon_access_key}&AssociateTag=#{amazon_associates_id}"
    end    
    
    # Call ItemLookup via REST.  Defaults to the 'Large' Response Group unless specified otherwise.
    def item_lookup(options)
      defaults = {:operation => 'ItemLookup', :response_group => 'Large'}
      
      get_response_with params_from(defaults.merge(options))
    end

    # Call ItemSearch via REST.  Defaults to 'Available' and to Response Groups of 'Medium, Offers' unless specified otherwise.
    def item_search(options)
      defaults = {:operation      => 'ItemSearch',
                  :availability   => 'Available', 
                  :response_group => 'Medium,Offers'}
      get_response_with params_from(defaults.merge(options))
    end
    
    # Call CartAdd via REST. Requires a options[:aws_cart_id] and options[:hmac] to be set to the 
    # cartid and HMAC returned from a previous CartCreate call.
    # 
    # Expects options[:asins] to be set to an array of ASINs as strings and will add all of these to 
    # the cart with quantity of 1.
    def add_to_cart(options)
      get_response_with '&Operation=CartAdd' +
                        "&CartId=#{options[:aws_cart_id]}&HMAC=#{options[:hmac]}" +
                        cart_params_for(options[:asin])
    end

    # Call CartClear via REST. Requires a options[:aws_cart_id] and options[:hmac] to be set to the 
    # cartid and HMAC returned from a previous CartCreate call.
    def clear_cart(options)    
      get_response_with '&Operation=CartClear' +
                        "&CartId=#{options[:aws_cart_id]}&HMAC=#{options[:hmac]}"
    end

    # Call CartCreate via REST.
    # 
    # Expects options[:asins] to be set to an array of ASINs as strings and will add all of these to 
    # the new cart with quantity of 1.    
    def create_cart(options)    
      get_response_with '&Operation=CartCreate' + 
                        cart_params_for(options[:asin])
    end
    
    # Call CartGet via REST. Requires a options[:aws_cart_id] and options[:hmac] to be set to the 
    # cartid and HMAC returned from a previous CartCreate call.
    def get_cart(options)
      get_response_with '&Operation=CartGet' +
                        "&CartId=#{options[:aws_cart_id]}&HMAC=#{options[:hmac]}"
    end  

    # Call CartModify via REST. Requires a options[:aws_cart_id] and options[:hmac] to be set to the 
    # cartid and HMAC returned from a previous CartCreate call.    
    #
    # This takes a single cartitemid and a new quantity (stored in options[:cart_item_id] and 
    # options[:quantity], respectively, sets the quantity of that cart item to the new value.
    def modify_cart(options)
      # TODO: consider supporting multiple item updates
      get_response_with '&Operation=CartModify' + 
                        "&CartId=#{options[:aws_cart_id]}&HMAC=#{options[:hmac]}" +
                        "&Item.1.CartItemId=#{options[:cart_item_id]}" +
                        "&Item.1.Quantity=#{options[:quantity]}"
    end
  
    def get_response_with request_params
      AmazonAWS::Response.new(fetch("#{@url_base}#{request_params}"))
    end

    def cart_params_for(asins)
      params = ''
      asins.each_with_index do |asin,index|
        params << "&Item.#{index+1}.ASIN=#{asin}&Item.#{index+1}.Quantity=1"
      end
      params
    end
    
    def params_from(options)
      params = ''
      # keys are sorted for testability
      # TODO: should we sort, then re-hashify for test only? Order doesn't matter for
      # 
      sorted_options = options.sort {|a,b| a[0].to_s <=> b[0].to_s}
      sorted_options.each do |pair|
        key   = pair[0]
        value = pair[1]
        params << 
          case key              
            when :actor
              "&Actor=#{URI.escape(Iconv.new('latin1', 'utf-8').iconv(value))}"
            when :artist
              "&Artist=#{URI.escape(Iconv.new('latin1', 'utf-8').iconv(value))}"
            when :asin
              "&ItemId=#{URI.escape(Iconv.new('latin1', 'utf-8').iconv(value))}"
            when :author
              "&Author=#{URI.escape(Iconv.new('latin1', 'utf-8').iconv(value))}"
            when :availability
              if 'Available' == value
                '&Availability=Available&MerchantId=Amazon&Condition=All'                        
              end
            when :browse_node
              "&BrowseNode=#{URI.escape(value)}"
            when :director
              "&Director=#{URI.escape(Iconv.new('latin1', 'utf-8').iconv(value))}"
            when :item_page
              "&ItemPage=#{URI.escape(value)}"
            when :keywords
              "&Keywords=#{URI.escape(Iconv.new('latin1', 'utf-8').iconv(value))}"
            when :operation
              "&Operation=#{URI.escape(value)}"
            when :response_group
              "&ResponseGroup=#{URI.escape(value)}"
            when :search_index
              "&SearchIndex=#{URI.escape(value)}"
            when :sort
              "&Sort=#{URI.escape(value)}"
            when :title
              "&Title=#{URI.escape(Iconv.new('latin1', 'utf-8').iconv(value))}"
          end
      end
      params
    end  

    # TODO: replace this with RESTClient: http://rest-client.heroku.com/rdoc/
    def fetch(url)
      case response = Net::HTTP.get_response(URI.parse(url))
        when Net::HTTPSuccess, Net::HTTPOK
          response.body
        when Net::HTTPRedirection
          fetch(response['location'])
        else
          response.error!
      end
    end

  end    
  
end