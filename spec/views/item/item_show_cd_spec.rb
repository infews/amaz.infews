require File.dirname(__FILE__) + '/../../spec_helper'

describe '/item/show', 'for a CD' do
  before :all do
    @lookup_response_single_disc = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_cd_2.xml')) 
    @lookup_response_two_disc = AmazonAWS::Response.new(File.read('spec/response_xml/item_lookup_cd.xml')) 
  end
  
  it 'should have the item summary at the top of the page' do
    assigns[:item] = ItemPresenter.new(@lookup_response_single_disc.items.first)
    
    render '/item/show'
      
    response.should have_tag('div#item') do
      with_tag('div.summary') do
        with_tag('div.artists', 'Vampire Weekend')
        with_tag('span.title', 'Vampire Weekend')
        with_tag('span.edition', '(Audio CD)')
      end
    end
  end
  
  it 'should have the label listed for a CD, if present' do
    assigns[:item] = ItemPresenter.new(@lookup_response_single_disc.items.first)
    
    render '/item/show'
      
    response.should have_tag('div#item') do
      with_tag('div.label', 'Xl Recordings')
    end
    
  end
  
  
  it 'should have the track listing for a CD, if present' do
    assigns[:item] = ItemPresenter.new(@lookup_response_single_disc.items.first)
    
    render '/item/show'
      
    response.should have_tag('div#item') do
      with_tag('div.disc') do
        without_tag('span.label', /Disc 1/)
      end
    end
  end
  
  it 'should have the track listing for a multiple-disc CD, if present' do
    assigns[:item] = ItemPresenter.new(@lookup_response_two_disc.items.first)
    
    render '/item/show'
      
    response.should have_tag('div#item') do
      with_tag('div.disc', /Disc 1/) do
        with_tag('li', 'In The Flesh?')
      end
      with_tag('div.disc', /Disc 2/) do
        with_tag('li', 'Run Like Hell')
      end      
    end
  end

  it 'should show the sales rank with rank group' do
    assigns[:item] = ItemPresenter.new(@lookup_response_two_disc.items.first)
    
    render '/item/show'
      
    response.should have_tag('div#rating_and_rank') do
      with_tag('div#rank') do
        with_tag('span.label', 'Amazon Sales Rank:')
        with_tag('span.rank', '173 in Music')
      end
    end
    
  end

end