require File.dirname(__FILE__) + '/../spec_helper'

describe ItemPresenter do
  
  # TODO: remove all the Response.new in favor of Hpricot.parse calls and/or mocks
  before :all do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_book.xml'))
    @book = ItemPresenter.new((aws_response.doc/:item).first)

    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_cd_2.xml'))
    @cd_2 = ItemPresenter.new((aws_response.doc/:item).first)
    
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_dvd_2.xml'))
    @dvd_2 = ItemPresenter.new((aws_response.doc/:item).first)

    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_not_discounted.xml'))
    @item_not_discounted = ItemPresenter.new((aws_response.doc/:item).first)
  end
  
  it 'should initialize with an Item doc node from an AWS Response' do
    @book.doc.class.should == Hpricot::Elem
  end

  it 'should get the Amazon price for the item' do
    @book.amazon_price.should == {:amount    => 1224,
                                  :formatted => '$12.24'}
  end

  it 'should get the ASIN of the item' do
    @book.asin.should == '0143112562'
  end
  
  it 'should get the author of a book when there is one author' do
    @book.authors.should == ['Thomas Pynchon']
  end

  it 'should get the authors of a book when there are multiple authors' do
    multi_author_repsonse = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_book_mult_authors.xml'))
    item = ItemPresenter.new((multi_author_repsonse.doc/:item)[0])

    item.authors.should == ['Stephen King', 'Peter Straub']
  end
  
  it 'should get the average customer rating of an item' do
    @book.average_rating.should == '4.5 out of 5 stars'
  end
  
  it 'should get the binding of the item' do
    @book.binding.should == 'Paperback'
  end
  
  it 'should get the editorial reviews of the item' do
    @book.editorial_reviews.should_not be_nil
    @book.editorial_reviews.first[:source].should == 'Product Description'
    @book.editorial_reviews.first[:content].should match(/^The inimitable Thomas Pynchon has done it again/)
    @book.editorial_reviews.first[:content].should_not match(/(&lt;|&gt;)/)
  end

  it 'should get all editorial reviews when there are multiple in the XML' do
    @cd_2.editorial_reviews.length.should == 2
  end
  
  it 'should get the edition of the item' do
    @book.edition.should == 'Reprint'
  end
  
  it 'should get the image information of the item' do
    @book.image.should_not be_nil
    @book.image[:url].should == 'http://ecx.images-amazon.com/images/I/41fafkIky5L._SL160_.jpg'
    @book.image[:height].should == '160'
    @book.image[:width].should == '104'
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
    @book.list_price.should == {:amount    => 1800, 
                                :formatted => '$18.00'}
  end

  it 'should get the number of cusotmer reviews of the item' do
    @book.number_of_reviews.should == '55'
  end

  it 'should get the Amazon sales rank of the item' do
    @book.sales_rank.should == '26771'  
  end
  
  it 'should get the title of the item' do
    @book.title.should == 'Against the Day'
  end
  
  it 'should get the artist of the item' do
    @cd_2.artists.should == ['Vampire Weekend']
  end
  
  it 'should get the label of the item' do
    @cd_2.label.should == 'Xl Recordings'
  end
  
  it 'should get the track listings of one disc' do
    @cd_2.tracks.should == [['Mansard Roof',
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
    @book.detail_page_url.should == 'http://www.amazon.com/gp/redirect.html%3FASIN=0143112562%26tag=ws%26lcode=xm2%26cID=2025%26ccmID=165953%26location=/o/ASIN/0143112562%253FSubscriptionId=0525E2PQ81DD7ZTWTK82'
  end
  
  it 'should return the product group' do
    @book.product_group.should == 'Book'
  end
  
  it 'should return an array of Directors, if present' do
    @dvd_2.directors.should == ['Steven Spielberg']
  end
  
  it 'should return the array of Format strings, if present' do
    @dvd_2.formats.length.should == 10
  end
  
  it 'should return the studio, if present' do
    @dvd_2.studio.should == 'Dreamworks Video'
  end
  
  it 'should return the correct summary partial name' do
    @book.summary_partial.should == 'book_summary'
    @cd_2.summary_partial.should == 'music_summary'
    @dvd_2.summary_partial.should == 'dvd_summary'
  end
  
  it 'should return the correct other details partial name' do
    @book.other_details_partial.should == 'book_other_details'
    @cd_2.other_details_partial.should == 'music_other_details'
    @dvd_2.other_details_partial.should == 'dvd_other_details'
  end

  it 'should report the sales rank group' do
    @book.rank_group.should == 'Books'
    @cd_2.rank_group.should == 'Music'
    @dvd_2.rank_group.should == 'Movies & TV'    
  end

  describe '#to_param' do
    it 'should return its ASIN from #to_param' do
      @book.to_param.should == '0143112562'
    end
  end
  
end