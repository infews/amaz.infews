require 'rubygems'

gem 'rspec'
require 'spec'
#require File.dirname(__FILE__) + '/../spec_helper'

require 'lib/amazon_aws'

class Dummy
  include AmazonAWS
end

describe AmazonAWS::Response do
  
  it 'should have a valid doc on init' do
    response = AmazonAWS::Response.new(File.read('spec/response_xml/item_search_book_keyword.xml'))
    response.doc.should_not be_nil
  end
  
end

