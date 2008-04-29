require File.dirname(__FILE__) + '/../../spec_helper'

describe '/item/show' do

  it 'should have the title summary at the top of the page' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_book.xml'))
    @item = ItemPresenter.new(aws_response.items.first)
    assigns[:item] = @item    
    
    render '/item/show'
      
    response.should have_tag('div#item') do
      with_tag('div.summary') do
        with_tag('span.title', 'Against the Day')
        with_tag('span.edition', '(Paperback, Reprint)')
      end
      with_tag('div.authors', 'by Thomas Pynchon')
    end
  end
  
  it 'should not hyperlink the title' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_book.xml'))
    @item = ItemPresenter.new(aws_response.items.first)
    assigns[:item] = @item    

    render '/item/show'
      
    response.should_not have_tag('a', 'Against the Day')
  end
  
  it 'should show the image if one is present' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_book.xml'))
    @item = ItemPresenter.new(aws_response.items.first)
    assigns[:item] = @item    
 
    render '/item/show'
      
    response.should have_tag('div#image') do
      with_tag('img')
    end
  end
  
  it 'should show the average rating' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_book.xml'))
    @item = ItemPresenter.new(aws_response.items.first)
    assigns[:item] = @item    
 
    render '/item/show'
      
    response.should have_tag('div#top_box') do
      with_tag('div#rating') do
        with_tag('div#stars', '4.5 out of 5 stars')
      end
    end
  end
  
  it 'should show the number of customer reviews' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_book.xml'))
    @item = ItemPresenter.new(aws_response.items.first)
    assigns[:item] = @item    
 
    render '/item/show'
      
    response.should have_tag('div#top_box') do
      with_tag('div#rating') do
        with_tag('div.count', '(55 customer reviews)')
      end
    end    
  end
  
  it 'should show the sales rank' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_book.xml'))
    @item = ItemPresenter.new(aws_response.items.first)
    assigns[:item] = @item    
 
    render '/item/show'
      
    response.should have_tag('div#top_box') do
      with_tag('div#rank') do
        with_tag('span.label', 'Amazon Sales Rank:')
        with_tag('span.rank', '26,771')
      end
    end
    
  end
  
  it 'should show the disclaimer at the bottom of the page' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_book.xml'))
    @item = ItemPresenter.new(aws_response.items.first)
    assigns[:item] = @item    
 
    render '/item/show'
      
    response.should have_tag('div#disclaimer') do
      with_tag('a')
      with_tag('em', /^Disclaimer/)
    end
  end

  it 'should show the description if a valid one is found' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_book.xml'))
    @item = ItemPresenter.new(aws_response.items.first)
    assigns[:item] = @item    
 
    render '/item/show'
      
    response.should have_tag('div#description') do
      with_tag('div.source')
      with_tag('div.content')
    end
  end
    
  it 'should not show a description if a valid one is not found' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_book_no_description.xml'))
    @item = ItemPresenter.new(aws_response.items.first)
    assigns[:item] = @item    
 
    render '/item/show'

    response.should_not have_tag('div#description')    
  end

  it 'should not show the 2nd pricing box if no description is shown' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_book_no_description.xml'))
    @item = ItemPresenter.new(aws_response.items.first)
    assigns[:item] = @item    
 
    render '/item/show'
    
    response.should have_tag('#item') do
      without_tag('div[class=pricing bottom]')
    end
  end
  
  it 'should show the price a 2nd time if there is a description' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_book.xml'))
    @item = ItemPresenter.new(aws_response.items.first)
    assigns[:item] = @item    
 
    render '/item/show'

    response.should have_tag('div[class=pricing bottom]')
  end
  
  it 'should not show an image if one is not present' do
    aws_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_book_missing_image.xml'))
    @item = ItemPresenter.new(aws_response.items.first)
    assigns[:item] = @item    
 
    render '/item/show'
    response.should have_tag('#item') do
      without_tag('img.item')
    end
  end
  
  it 'should show the list price if it is more than the amazon price'
  it 'should not show the amazon price it is not less than the list price' 
  it 'should have each author linked to a search'
end