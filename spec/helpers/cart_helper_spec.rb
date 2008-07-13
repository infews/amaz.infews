require File.dirname(__FILE__) + '/../spec_helper'

describe CartHelper do
  describe '#quantity_text' do
    
    it 'should show nothing if the quantity of an item is 1' do
      cart_item = mock('cart_item_presenter', :quantity => '1')
      
      helper.quantity_text(cart_item).should == ''
    end
    
    it 'should show the quantity if the quantity is > 1' do
      cart_item = mock('cart_item_presenter', :quantity => '5')
      
      helper.quantity_text(cart_item).should == '(5 copies)'      
    end
  end
end
