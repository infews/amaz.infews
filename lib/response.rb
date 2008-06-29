require 'hpricot'

module AmazonAWS
  
  class Response
    attr_reader :doc
    
    def initialize(xml)
      @doc = Hpricot.parse(xml)
    end
    
    def items
      @doc/'//items/item'.inject([]) do |array, item_node|
        array << item_node
      end
    end
    
    def cart_items
      @doc/'cart/cartitems/cartitem'.inject([]) do |array, item_node|
        array << item_node
      end
    end
    
    def errors
      @errors_node ||= @doc/'request/errors/error'
      
      return nil if @errors_node.empty?
        
      @errors ||= {:code => (@errors_node/:code).innerHTML, 
                   :message => (@errors_node/:message).innerHTML}
    end
  end
  
end