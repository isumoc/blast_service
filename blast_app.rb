require 'sinatra/base'
require 'sidekiq'
require 'sidekiq/api'
require 'sidekiq/web'

require_relative 'lib/workers/blast_worker.rb'

class BlastApp < Sinatra::Base
  post '/blastp' do
    uploaded_fasta = params[:data][:tempfile].path
    job_id = BlastWorker.perform_async(uploaded_fasta)
    "see status: http://localhost:3000/status/#{job_id}.html"
  end
end
