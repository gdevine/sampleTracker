# require 'rvm/capistrano'
# require 'bundler/capistrano'

set :application, "sampleTracker"
set :repository,  "git@github.com:gdevine/sampleTracker.git"
set :deploy_to, "/var/www/html/sampletracker"
set :scm, :git
set :branch, "master"
set :user, "30036712"
set :group, "deployers"
set :use_sudo, false
set :rails_env, "production"
set :deploy_via, :copy
set :ssh_options, { :forward_agent => true}
set :keep_releases, 5
default_run_options[:pty] = true
server "u0177.uws.edu.au", :app, :web, :db, :primary => true

namespace :deploy do
  
  #
  # Make a symbolic link to where database.yml is stored
  #
  desc "Symlink shared config files"
  task :symlink_config_files do
    run "#{ try_sudo } ln -s #{ deploy_to }/shared/config/database.yml #{ release_path }/config/database.yml"
    #run "#{ try_sudo } ln -nfs #{ shared_path }/config/database.yml #{ release_path }/config/database.yml"
  end


  #
  # Restart the server through Passenger
  #
  desc "Restart Passenger app"
  task :restart do
    run "#{ try_sudo } touch #{ File.join(current_path, 'tmp', 'restart.txt') }"
  end
end


after "deploy", "deploy:symlink_config_files"
after "deploy", "deploy:restart"
after "deploy", "deploy:cleanup"


# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

# role :web, "your web-server here"                          # Your HTTP server, Apache/etc
# role :app, "your app-server here"                          # This may be the same as your `Web` server
# role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
