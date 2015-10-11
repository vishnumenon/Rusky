require 'sinatra'
require 'pg'
require 'sinatra/sequel'

configure do
  DB = Sequel.connect(ENV['DATABASE_URL']);
  DB.create_table! :vendors do
    primary_key :id
    int8 :fb_id
    varchar :name
    varchar :cuisine
    varchar :secret
  end
  DB.create_table! :users do
    primary_key :id
    varchar :name
    varchar :username
    varchar :password
  end
  DB.create_table! :requests do
    primary_key :id
    float8 :latitude
    float8 :longitude
    varchar :username
  end
end
class Vendor < Sequel::Model; end
class User < Sequel::Model; end
class Request < Sequel::Model; end

get '/' do
  vendors = DB.from(:vendors)
  allV = vendors.all
  erb :index, :locals => {:allVendors => allV}
end

get '/vendor/new' do
  erb :newVendor
end

post '/vendor/new' do
  Vendor.create(params);
  erb :vendorCreated
end
