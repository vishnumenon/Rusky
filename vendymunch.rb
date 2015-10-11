require 'sinatra'
require 'pg'
require 'json'
require 'sinatra/sequel'

#=== CENTROID CALCULATIONS

def distance(x1,x2,y1,y2)
	return Math.sqrt((x1-x2)**2 + (y1-y2)**2)
end

def centroidCalc(set)
	sumX=0
	sumY=0
	for i in 0...set.length
		sumX+=set[i][0]
		sumY+=set[i][1]
	end
	return [sumX.to_f/set.length,sumY.to_f/set.length]
end

def kmeans(people)
	peopleNumber=people.length
	multiplier=[1,1]
	personX=people[0][0]
	personY=people[0][1]

	for i in 0...peopleNumber
		for k in 0...2
			people[i][k]=people[i][k].abs
		end
	end
	groupOne=[people[0]]
	groupTwo=[people[peopleNumber/2]]
	centroid=[groupOne[0],groupTwo[0]]
	for i in 0...peopleNumber
		if(distance(centroid[0][0],people[i][0],centroid[0][1],people[i][1]) < distance(centroid[1][0],people[i][0],centroid[1][1],people[i][0]))
			groupOne[groupOne.length]=people[i]
			centroid[0]=centroidCalc(groupOne)
		else
			groupTwo[groupTwo.length]=people[i]
			centroid[1]=centroidCalc(groupTwo)
		end
	end

	for i in 0...groupOne.length
		if(distance(centroid[0][0],groupOne[i][0],centroid[0][1],groupOne[i][1]) > distance(centroid[1][0],groupOne[i][0],centroid[1][1],groupOne[i][1]))
			groupTwo[groupTwo.length]=groupOne[i]
			groupOne.delete_at(i)
		end
	end

	groupOne.delete_at(0)
	groupTwo.delete_at(0)
	centroid[0]=centroidCalc(groupOne)
	centroid[1]=centroidCalc(groupTwo)

	if personX<0
		multiplier[0]=-1
	end
	if personY<0
		multiplier[1]=-1
	end
	for i in 0...centroid.length
		centroid[i][0]*=multiplier[0]
		centroid[i][1]*=multiplier[1]
	end
  if(groupOne.length > groupTwo.length)
    return centroid[0]
  else
    return centroid[1]
  end
end

#======= END CENTROID STUFF
Sequel::Model.plugin :json_serializer

configure do
  DB = Sequel.connect(ENV['DATABASE_URL']);
  DB.create_table? :vendors do
    primary_key :id
    int8 :fb_id
    varchar :name
    varchar :cuisine
    varchar :secret
  end
  DB.create_table? :requests do
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
  # reqs = DB.from(:requests)
  # vendorReqs = reqs.where(:vendor => params["id"])
  # vendorReqs.to_hash.to_json
  Request.filter(:vendor => params["id"].to_i).to_json
end

get '/centroid/:fbid' do
  content_type :json
  v = Vendor.filter(:fb_id => params[:fbid]).first
  myVID = v[:id]
  rs = Request.filter(:vendor => myVID)
  people=[];
  rs.each { |r|
    people.push([r.latitude, r.longitude])
  }
    puts people.to_s
    puts "KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK"
  centroid = kmeans(people)
  puts "KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK"
  puts people.to_s
  puts "KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK"
  puts centroid.to_s
  puts "KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK"
  return {:latitude => centroid[0], :longitude => centroid[1]}.to_json
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
  relevantReqs = Request.filter(:vendor => params["id"].to_i)
  erb :vendor
end
