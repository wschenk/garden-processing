require 'bundler'

Bundler.require

require './app.rb'

mime_type :coffee, "text/coffeescript"

run Sinatra::Application