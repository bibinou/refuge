set :application, "refuge"
set :repository,  "git@github.com:la-cordee/refuge.git"
set :keep_releases, 2
set :deploy_to, "/home/refuge"
set :use_sudo, false
set :scm, 'git'
set :default_stage, 'development'
set :branch, fetch(:branch, "production")

role :web, "ns382592.ovh.net"
role :app, "ns382592.ovh.net"
role :db,  "ns382592.ovh.net", :primary => true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :symlink_shared do
    run "ln -s #{shared_path}/config/database.yml #{release_path}/config/"
    run "rm -rf #{release_path}/public && ln -s #{shared_path}/public #{release_path}/public"
  end

end

namespace :dragonfly do
  desc "Symlink the Rack::Cache files"
  task :symlink, :roles => [:app] do
    run "mkdir -p #{shared_path}/tmp/dragonfly && ln -nfs #{shared_path}/tmp/dragonfly #{release_path}/tmp/dragonfly"
  end
end

after 'deploy:update_code', 'dragonfly:symlink'
before "deploy:restart", "deploy:symlink_shared"

