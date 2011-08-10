#config.ru
require "#{Pathname(__FILE__).dirname}/the_word_is_watching.rb"
disable :run
set :root, Pathname(__FILE__).dirname
set :logging, true
set :dump_errors, true
set :show_exceptions, true
run Sinatra::Application
