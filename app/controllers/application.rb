# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AmazonAWS
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'd49d941c59fe933cf1635c3e2200feb4'

  def amazon_associates_id
    'infews-20'
  end
  
  # Must return a string that is your Amazon API Access Key
  def amazon_access_key    
    '0124C8E5VGPVEVHH0J02'
  end

end