require File.dirname(__FILE__) + '/../../spec_helper'

describe '/item/show', 'for a DVD' do
  before :all do
    @lookup_response_dvd = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_dvd_2.xml')) 
  end
  
  it 'should have the item summary at the top of the page' do
    assigns[:item] = ItemPresenter.new(@lookup_response_dvd.items.first)
    
    render '/item/show'
      
    response.should have_tag('div#item') do
      with_tag('div.summary') do
        with_tag('span.title', 'Saving Private Ryan (Special Limited Edition)')
        with_tag('span.edition', '(DVD)')
      end
    end
  end
  
  it 'should have the director in the other details, if present' do
    assigns[:item] = ItemPresenter.new(@lookup_response_dvd.items.first)

    render '/item/show'
      
    response.should have_tag('div#item') do
      with_tag('div.directors') do
        with_tag('span.label', 'Directed by')
        with_tag('a', 'Steven Spielberg')
      end
    end

  end
  
  it 'should have the actors list if present' do
    assigns[:item] = ItemPresenter.new(@lookup_response_dvd.items.first)

    render '/item/show'
      
    response.should have_tag('div#item') do
      with_tag('div.actors') do
        with_tag('span.label', 'Starring')
        with_tag('a', 'Tom Hanks')
      end
    end
  end
  
  it 'should not have a director in the other details section if not present' do
    lookup_response = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_dvd.xml')) 
    assigns[:item] = ItemPresenter.new(lookup_response.items.first)

    render '/item/show'
      
    response.should have_tag('div#item') do
      without_tag('div.directors')
    end
 
  end

  it 'should have a formats list if present' do
    assigns[:item] = ItemPresenter.new(@lookup_response_dvd.items.first)

    render '/item/show'
      
    response.should have_tag('div#item') do
      with_tag('div.formats') do
        with_tag('span.label', 'Formats:')
      end
    end
  end

  it 'should have the audience rating if present' do
    assigns[:item] = ItemPresenter.new(@lookup_response_dvd.items.first)

    render '/item/show'
      
    response.should have_tag('div#item') do
      with_tag('div.mpaa') do
        with_tag('span.label', 'Rated')        
      end
    end    
  end
  
  it 'should have the asepct ratio if present' do
    assigns[:item] = ItemPresenter.new(@lookup_response_dvd.items.first)

    render '/item/show'
      
    response.should have_tag('div#item') do
      with_tag('div.aspect_ratio') do
        with_tag('span.label', 'Aspect Ratio:')
      end
    end

  end
  
  it 'should have the asepct ratio if present' do
    assigns[:item] = ItemPresenter.new(@lookup_response_dvd.items.first)

    render '/item/show'
      
    response.should have_tag('div#rating_and_rank') do
      with_tag('div#rank') do
        with_tag('span.label', 'Amazon Sales Rank:')
        with_tag('span.rank', '654 in Movies & TV')
      end
    end

  end
  
end