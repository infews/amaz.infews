require File.dirname(__FILE__) + '/../spec_helper'

describe ItemPresenter do
  
  before :all do
    missing_tags_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_missing_tags.xml'))
    @item = ItemPresenter.new((missing_tags_response.doc/:item).first)
  end
  
  it 'should return nil for Amazon price if Amazon is not selling the item (no offers in the response)' do
    @item.amazon_price.should be_nil    
  end
  
  it 'should return nil when there are no authors of this item' do
    @item.authors.should be_nil
  end
  
  it 'should return "No Customer Ranknings" when there is no average customer rating of an item' do
    @item.average_rating.should == 'No Customer Ratings'
  end
  
  it 'should return nil if the binding is not present' do
    @item.binding.should be_nil
  end
    
  it 'should return nil if the edition is not present' do
    @item.edition.should be_nil
  end
   
  it 'should return nil if there are no images on Amazon for the item' do
    @item.image.should be_nil    
  end
  
  it 'should return nil for list price if there is no list price of the item' do
    @item.list_price.should be_nil
  end

  it 'should return nil for number_of_reviews is there are none for this item' do
    @item.number_of_reviews.should be_nil
  end
  
  it 'should return nil for sales rank if this item is not ranked' do
    @item.sales_rank.should be_nil
  end
  
end