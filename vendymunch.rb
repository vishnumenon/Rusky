require 'sinatra'
require 'pg'
require 'json'
require 'sinatra/sequel'

configure do
  DB = Sequel.connect(ENV['DATABASE_URL']);
  DB.create_table? :vendors do
    primary_key :id
    int8 :fb_id
    varchar :name
    varchar :cuisine
    varchar :secret
  end
  DB.create_table! :requests do
    primary_key :id
    float8 :latitude
    float8 :longitude
    int8 :vendor
  end
end
class Vendor < Sequel::Model; end
class Request < Sequel::Model; end

get '/' do
  vendors = DB.from(:vendors)
  allV = vendors.all
  erb :index, :locals => {:allVendors => allV}
end

get '/requests/:id' do
  content_type :json
  reqs = DB.from(:requests)
  vendorReqs = reqs.where(:vendor => params["id"])
  vendorReqs.to_json
end

post '/requests/new' do
  content_type :json
  Request.create(params)
  {"status" => "success"}.to_json
end

get '/vendor/new' do
  erb :newVendor
end

post '/vendor/new' do
  Vendor.create(params);
  erb :vendor
end

get '/vendor' do
  erb :vendor
end
