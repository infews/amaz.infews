ExceptionNotifier.exception_recipients = %w(crash@infe.ws)

ActionMailer::Base.smtp_settings = { :address => 'smtp.gmail.com',
                                     :port => "587",
                                     :tls => true,
                                     :authentication => :plain,
                                     :domain => 'infe.ws',
                                     :user_name => 'infews@infe.ws',
                                     :password => 'scotch4code' }