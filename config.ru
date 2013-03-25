require './main'
run Sinatra::Application

set :environment, :development
set :server, :thin
set :database, ENV['DATABASE_URL'] || 'postgres://localhost/mt1'
