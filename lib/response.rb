require 'hpricot'

module AmazonAWS
  
  class Response
    attr_reader :doc
    
    def initialize(xml)
      @doc = Hpricot.parse xml
    end
    
  end
  
end