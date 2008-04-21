require 'hpricot'

module AmazonAWS
  
  class Response
    attr_reader :doc
    
    def initialize(doc)
      @doc = doc
    end
    
  end
  
end