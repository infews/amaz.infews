default_run_options[:pty] = true

set :application, 'amaz.infews'
set :repository,  'git@github.com:infews/amaz.infews.git'
set :scm, "git"
set :scm_passphrase, 'scotch4code' #This is your custom users password
set :user, 'infews'
set :use_sudo, true

role :app, "infews-prod1"
role :web, "infews-prod1"
role :db,  "infews-prod1", :primary => true