class AwsItemPresenter

  def self.attr_reader_from_xml(symbol, xpath)
    self.class_eval """def #{symbol}
                         @#{symbol} ||= get('#{xpath}')
                       end
                    """
  end
  
  private
  
  def get(xpath)
    node = @doc%xpath
    node.nil? ? nil : node.innerHTML
  end
  
end