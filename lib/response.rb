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
  end
  
end