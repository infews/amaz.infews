# = AmazonAWS
# This Ruby library abstracts a useful subset of the Amazon E-Commerce Services API.
# 
# TODO: Put some usage examples here
# 
# == Colophon
#  Copyright 2006-2008 Infews, LLC.  Provided via the Ruby license

# Definition of all supported countries' base URLs.  Your code must require
require 'lib/request'
require 'lib/response'

module AmazonAWS
  # TODO: add other countries as support is added
  AWS_URL_US = 'http://webservices.amazon.com/onca/xml?Service=AWSECommerceService'
  DISCLAIMER = 'Disclaimer: Prices are accurate as of the date/time indicated. Prices and product availability are subject to change. Any price displayed on the Amazon website at the time of purchase will govern the sale of this product.'
  AWS_URL    = AWS_URL_US unless const_defined?(:AWS_URL)

  def aws_item_lookup(options)
    aws_request.item_lookup(options)
  end

  def aws_item_search(options)
    aws_request.item_search(options)    
  end
  
  def aws_add_to_cart(options)
    aws_request.add_to_cart(options)
  end
  
  def aws_clear_cart(options)
    aws_request.clear_cart(options)
  end
  
  def aws_create_cart(options)
    aws_request.create_cart(options)
  end
  
  def aws_get_cart(options)
    aws_request.get_cart(options)
  end
  
  def aws_modify_cart(options)
    aws_request.modify_cart(options)
  end
  
  # Must return a string that is your Amazon Associates ID.
  def amazon_associates_id
    # TODO: if we make an Exception class, then add this as a proper Exception
    raise 'AmazonECS needs you to define <included>#amazon_associates_id'
  end
  
  # Must return a string that is your Amazon API Access Key
  def amazon_access_key    
    # TODO: if we make an Exception class, then add this as a proper Exception
    raise 'AmazonECS needs you to define <included>#amazon_access_key'
  end

end