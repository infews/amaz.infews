set :application, "amaz.infews"
set :repository,  "set your repository location here"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

set :scm, :git

role :app, "infews-prod1"
role :web, "infews-prod1"
role :db,  "infews-prod1", :primary => true