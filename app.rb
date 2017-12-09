require 'date'
require 'json'
require 'uri'
require 'bundler'

require_relative './database'

Bundler.require

VERSION = '2.0'

error do
  <<-ERROR
Error: #{env['sinatra.error']}

Backtrace: #{env['sinatra.error'].backtrace.join("\n")}
  ERROR
end

get '/' do
  result = {
    version: VERSION,
    environment: ENV.to_h
  }
  JSON.pretty_generate result
end

get '/ping' do
  result = {
    status: "OK"
  }
  JSON.pretty_generate result
end

get '/env' do
  result = ENV.to_h
  JSON.pretty_generate result
end

get '/database' do
  result = {
    credentials: Database.instance.credentials
  }
  JSON.pretty_generate result
end

get '/store/:key' do
  key = params[:key]
  value = Database.instance.get_key key

  result = {
    meta: {
      store_time: DateTime.now.to_s
    },
    key: key,
    value: value
  }
  JSON.pretty_generate result
end

post '/store/:key' do
  value = request.env["rack.input"].read
  key = params[:key]

  Database.instance.store_value key, value
  result = {
    meta: {
      retrieval_time: DateTime.now.to_s
    },
    key: key,
    value: value
  }
  JSON.pretty_generate result
end
