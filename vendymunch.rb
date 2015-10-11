require 'sinatra'
#require 'sinatra/sequel'
# 
# DB = Sequel.sqlite
# DB.create_table :trucks do
#   primary_key :id
#   varchar :name
#   varchar :cuisine
#   varchar :username
#   varchar :password
# end
# class Link < Sequel::Model; end

get '/truck/new' do
  erb :registerTruck
end

post '/truck/new' do
  erb :truckCreated
end
