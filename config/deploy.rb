require 'mongrel_cluster/recipes'
default_run_options[:pty] = true

set :application, 'amaz.infews'
set :repository,  'git@github.com:infews/amaz.infews.git'
set :scm, "git"
set :scm_passphrase, 'scotch4code'
set :user, 'infews'
set :use_sudo, true

role :app, "infews-prod1"
role :web, "infews-prod1"
role :db,  "infews-prod1", :primary => true

set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"