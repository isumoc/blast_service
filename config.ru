require File.expand_path('blast_app', File.dirname(__FILE__))

run Rack::URLMap.new('/' => BlastApp, '/sidekiq' => Sidekiq::Web)
