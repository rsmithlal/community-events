#
set :deploy_to, "/opt/www/planner"
set :user, "henry"
set :rails_env, "loncon" 
server '176.58.104.226', :app, :web, :db, :primary => true
