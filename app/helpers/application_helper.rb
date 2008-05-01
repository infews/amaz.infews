# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
 
  include ActionView::Helpers::TextHelper   # included for #pluralize
  include ActionView::Helpers::NumberHelper # included for number_with_delimiter
  
  def pluralize_with_delimiter(count, singular, plural = nil, delimiter = ',')
    pluralize(count, singular, plural).sub(count.to_s, number_with_delimiter(count, delimiter))
  end    

end
