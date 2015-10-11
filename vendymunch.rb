require 'sinatra'
require 'pg'
require 'sinatra/sequel'

configure do
  DB = Sequel.connect(ENV['DATABASE_URL']);
  DB.create_table :trucks do
    primary_key :id
    varchar :name
    varchar :cuisine
    varchar :username
    varchar :password
  end
end
class Link < Sequel::Model; end

get '/' do
  erb :index
end

get '/vendor/new' do
  erb :registerVendor
end

post '/vendor/new' do
  erb :vendorCreated
end
