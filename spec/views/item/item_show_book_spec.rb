require File.dirname(__FILE__) + '/../../spec_helper'

describe '/item/show' do
  before :all do
    @lookup_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_book.xml')) 
  end
  
  it 'should have the item summary at the top of the page' do
    assigns[:item] = ItemPresenter.new(@lookup_response.items.first)
    
    render '/item/show'
      
    response.should have_tag('div#item') do
      with_tag('div.summary') do
        with_tag('span.title', 'Against the Day')
        with_tag('span.edition', '(Paperback, Reprint)')
      end
      with_tag('div.authors', 'by Thomas Pynchon')
    end
  end
  
  it 'should not show the edition info there is no binding and no edition present' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_missing_tags.xml'))
    assigns[:item] = ItemPresenter.new(aws_response.items.first)
    
    render '/item/show'
    
    response.should have_tag('div#item') do
      without_tag('span.edition')
    end
  end

# TODO: is this testable with rspec?  should it even be tested?
#   
#  it 'should not hyperlink the title' do
#    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_book.xml'))
#    @item = ItemPresenter.new(aws_response.items.first)
#    assigns[:item] = @item    
#
#    render '/item/show'
#      
#    response.should_not have_tag('a', 'Against the Day')
#  end
  
  it 'should show the image if one is present' do
    assigns[:item] = ItemPresenter.new(@lookup_response.items.first)
 
    render '/item/show'
      
    response.should have_tag('div#image') do
      with_tag('img')
    end
  end
  
  it 'should show the average rating' do
    assigns[:item] = ItemPresenter.new(@lookup_response.items.first)
    
    render '/item/show'
      
    response.should have_tag('div#rating_and_rank') do
      with_tag('div#rating') do
        with_tag('div#stars', '4.5 out of 5 stars')
      end
    end
  end
  
  it 'should show the number of customer reviews' do
    assigns[:item] = ItemPresenter.new(@lookup_response.items.first)
    
    render '/item/show'
      
    response.should have_tag('div#rating_and_rank') do
      with_tag('div#rating') do
        with_tag('div.count', '(55 customer reviews)')
      end
    end    
  end
  
  it 'should show the sales rank' do
    assigns[:item] = ItemPresenter.new(@lookup_response.items.first)
    
    render '/item/show'
      
    response.should have_tag('div#rating_and_rank') do
      with_tag('div#rank') do
        with_tag('span.label', 'Amazon Sales Rank:')
        with_tag('span.rank', '26,771')
      end
    end
    
  end
  
  it 'should show the disclaimer at the bottom of the page' do
    assigns[:item] = ItemPresenter.new(@lookup_response.items.first)
    
    render '/item/show'
      
    response.should have_tag('div#disclaimer') do
      with_tag('a', /^Disclaimer/)
    end
  end

  it 'should show the editorial reviews if a valid one is found' do
    assigns[:item] = ItemPresenter.new(@lookup_response.items.first)
    
    render '/item/show'
      
    response.should have_tag('div.review') do
      with_tag('div.source')
      with_tag('div.content')
    end
  end
    
  it 'should not show editorial reviews if there are none in the response' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_book_no_description.xml'))
    assigns[:item] = ItemPresenter.new(aws_response.items.first)
 
    render '/item/show'

    response.should_not have_tag('div#description')    
  end

  it 'should not show the 2nd pricing box if no description is shown' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_book_no_description.xml'))
    assigns[:item] = ItemPresenter.new(aws_response.items.first)
 
    render '/item/show'
    
    response.should have_tag('#item') do
      without_tag('div[class=pricing bottom]')
    end
  end
  
  it 'should show the price a 2nd time if there is a description' do
    assigns[:item] = ItemPresenter.new(@lookup_response.items.first)
    
    render '/item/show'

    response.should have_tag('div[class=pricing bottom]')
  end
  
  it 'should not show an image if one is not present' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_book_missing_image.xml'))
    assigns[:item] = ItemPresenter.new(aws_response.items.first)
 
    render '/item/show'
    response.should have_tag('#item') do
      without_tag('img.item')
    end
  end
  
  it 'should show the list price if it is more than the amazon price'
  it 'should not show the amazon price it is not less than the list price'
  
  it 'should have each author linked to a search' do
    assigns[:item] = ItemPresenter.new(@lookup_response.items.first)
    
    render '/item/show'

    # TODO: once the url for search is settled, match the <A>'s href
    response.should have_tag('.summary') do
      with_tag('.authors') do
        with_tag('a','Thomas Pynchon')
      end
    end    
  end
  
end