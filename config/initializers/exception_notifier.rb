require 'smtp_tls'

ExceptionNotifier.exception_recipients = %w(crash@infe.ws)

ActionMailer::Base.server_settings = { :address => 'smtp.gmail.com',
                                       :port => "587",
                                       :authentication => :plain,
                                       :domain => 'infe.ws',
                                       :user_name => 'infews@infe.ws',
                                       :password => 'scotch4code'}