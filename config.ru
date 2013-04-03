require './main'
run Sinatra::Application

set :environment, :development
set :server, :thin
set :database, ENV['DATABASE_URL'] || 'postgres://localhost/mt1'
set :public_folder, 'public'
set :haml, :format => :html5

error do
  'Sorry there was a nasty error - ' + env['sinatra.error'].name
end

