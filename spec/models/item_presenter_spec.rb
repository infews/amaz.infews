require File.dirname(__FILE__) + '/../spec_helper'

describe ItemPresenter do
  
  before :all do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_book.xml'))
    @item = ItemPresenter.new((aws_response.doc/:item).first)
    # make a response from XML
  end
  
  it 'should initialize with an Item doc node from an AWS Response' do
    @item.doc.class.should == Hpricot::Elem
  end

  it 'should get the Amazon price for the item' do
    @item.amazon_price.should == {:amount    => 1224,
                                  :formatted => '$12.24'}
  end

  it 'should get the ASIN of the item' do
    @item.asin.should == '0143112562'
  end
  
  it 'should get the author of a book when there is one author' do
    @item.authors.should == ['Thomas Pynchon']
  end

  it 'should get the authors of a book when there are multiple authors' do
    multi_author_repsonse = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_book_mult_authors.xml'))
    item = ItemPresenter.new((multi_author_repsonse.doc/:item)[0])

    item.authors.should == ['Stephen King', 'Peter Straub']
  end
  
  it 'should get the average customer rating of an item' do
    @item.average_rating.should == '4.5'
  end
  
  it 'should get the binding of the item' do
    @item.binding.should == 'Paperback'
  end
  
  it 'should get the description of the item' do
    @item.description.should_not be_nil
    @item.description[:source].should == 'Product Description'
    @item.description[:content].should match(/^The inimitable Thomas Pynchon has done it again/)
  end

  it 'should get the edition of the item' do
    @item.edition.should == 'Reprint'
  end
  
  it 'should get the image information of the item' do
    @item.image.should_not be_nil
    @item.image[:url].should == 'http://ecx.images-amazon.com/images/I/41fafkIky5L._SL160_.jpg'
    @item.image[:height].should == '160'
    @item.image[:width].should == '104'
  end
  
  it 'should get the small image information of the item if there is no medium image info' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_no_medium_image.xml'))
    item = ItemPresenter.new((aws_response.doc/:item).first)
    
    item.image.should_not be_nil
    item.image[:url].should == 'http://ecx.images-amazon.com/images/I/41fafkIky5L._SL75_.jpg'
    item.image[:height].should == '75'
    item.image[:width].should == '49'    
  end
  
  it 'should get the list price of the item' do
    @item.list_price.should == {:amount    => 1800, 
                                :formatted => '$18.00'}
  end

  it 'should get the number of cusotmer reviews of the item' do
    @item.number_of_reviews.should == '55'
  end

  it 'should get the Amazon sales rank of the item' do
    @item.sales_rank.should == '26771'  
  end
  
  it 'should get the title of the item' do
    @item.title.should == 'Against the Day'
  end
  
end