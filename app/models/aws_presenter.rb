class AwsPresenter
  
  attr_reader :doc

  def self.attr_from_xml(symbol, xpath)
    self.class_eval """def #{symbol}
                         @#{symbol} ||= get('#{xpath}')
                       end
                    """
  end
  
  def self.attr_array_from_xml(symbol, xpath = '//itemattributes', leaf = '')
    tag = symbol.to_s.sub(/s$/, '')
    self.class_eval  """def #{symbol}
                          node = @doc%'#{xpath}'
                          @#{symbol} ||= node.children_of_type('#{tag}').inject([]) do |foos, a_foo|
                                           foos << a_foo.innerHTML
                                         end
                        rescue
                          []    
                        end
                     """
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