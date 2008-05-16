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
    @item.average_rating.should == '4.5 out of 5 stars'
  end
  
  it 'should get the binding of the item' do
    @item.binding.should == 'Paperback'
  end
  
  it 'should get the editorial reviews of the item' do
    @item.editorial_reviews.should_not be_nil
    @item.editorial_reviews.first[:source].should == 'Product Description'
    @item.editorial_reviews.first[:content].should match(/^The inimitable Thomas Pynchon has done it again/)
    @item.editorial_reviews.first[:content].should_not match(/(&lt;|&gt;)/)
  end

  it 'should get all editorial reviews when there are multiple in the XML' do
    multi_editorial_review_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_cd_2.xml'))
    item = ItemPresenter.new((multi_editorial_review_response.doc/:item)[0])
    
    item.editorial_reviews.length.should == 2
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
  
  it 'should get the artist of the item' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_cd_2.xml'))
    item = ItemPresenter.new((aws_response.doc/:item).first)

    item.artists.should == ['Vampire Weekend']
  end
  
  it 'should get the label of the item' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_cd_2.xml'))
    item = ItemPresenter.new((aws_response.doc/:item).first)

    item.label.should == 'Xl Recordings'
  end
  
  it 'should get the track listings of one disc' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_cd_2.xml'))
    item = ItemPresenter.new((aws_response.doc/:item).first)

    item.tracks.should == [['Mansard Roof',
                            'Oxford Comma',
                            'A-Punk',
                            'Cape Cod Kwassa Kwassa',
                            'M79',
                            'Campus',
                            'Bryn',
                            "One (Blake's Got A New Face)",
                            'I Stand Corrected',
                            'Walcott',
                            "The Kids Don't Stand A Chance"]]
  end
  
  it 'should get the track listings of a multi-disc CD' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_cd.xml'))
    item = ItemPresenter.new((aws_response.doc/:item).first)
    
    item.tracks.should == [['In The Flesh?',
                            'The Thin Ice',
                            'Another Brick In The Wall, Part 1',
                            'The Happiest Days Of Our Lives',
                            'Another Brick In The Wall, Part 2',
                            'Mother',
                            'Goodbye Blue Sky',
                            'Empty Spaces',
                            'Young Lust',
                            'One Of My Turns',
                            "Don't Leave Me Now",
                            'Another Brick In The Wall (Part III)',
                            'Goodbye Cruel World'],
                           ['Hey You',
                            'Is There Anybody Out There?',
                            'Nobody Home',
                            'Vera',
                            'Bring the Boys Back Home',
                            'Comfortably Numb',
                            'The Show Must Go On',
                            'In The Flesh',
                            'Run Like Hell',
                            'Waiting For The Worms',
                            'Stop',
                            'The Trial',
                            'Outside The Wall']]
  end
  
  
  it 'should return an array of Actors if present' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_dvd.xml'))
    item = ItemPresenter.new((aws_response.doc/:item).first)
    
    item.actors.length.should == 5
    item.actors[0].should == 'Fran Drescher'    
  end
  
  it 'should return the Audience Rating if present' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_dvd.xml'))
    item = ItemPresenter.new((aws_response.doc/:item).first)

    item.audience_rating.should == 'R (Restricted)'
  end
  
  it 'should return the Amazon detail URL' do
    @item.detail_page_url.should == 'http://www.amazon.com/gp/redirect.html%3FASIN=0143112562%26tag=ws%26lcode=xm2%26cID=2025%26ccmID=165953%26location=/o/ASIN/0143112562%253FSubscriptionId=0525E2PQ81DD7ZTWTK82'
  end
  
  it 'should return the product group' do
    @item.product_group.should == 'Book'
  end
  
  it 'should return an array of Directors, if present' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_dvd_2.xml'))
    item = ItemPresenter.new((aws_response.doc/:item).first)

    item.directors.should == ['Steven Spielberg']
  end
  
  it 'should return the array of Format strings, if present' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_dvd_2.xml'))
    item = ItemPresenter.new((aws_response.doc/:item).first)
    
    item.formats.length.should == 10
  end
  
  it 'should return the studio, if present' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_dvd_2.xml'))
    item = ItemPresenter.new((aws_response.doc/:item).first)
    
    item.studio.should == 'Dreamworks Video'
  end
  
end