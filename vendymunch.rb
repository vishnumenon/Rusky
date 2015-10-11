require 'sinatra'
require 'pg'
require 'json'
require 'sinatra/sequel'

#=== CENTROID CALCULATIONS

def distance(p1,p2)
	return Math.sqrt((p1[0]-p2[0])**2 + (p1[1]-p2[1])**2)
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


def kmeans(people,ncluster)
	peopleNumber=people.length
	multiplier=[1,1]
	personX=people[0][0]
	personY=people[0][1]
	centroid=[]
	finalCentroid=[]
	finalGroups=[]
	for i in 0...peopleNumber
		for k in 0...2
			people[i][k]=people[i][k].abs
		end
	end


	sizeOfCluster=peopleNumber/ncluster

	finalGroups[0] = []
	finalGroups[0].push(people[0])
	#finalGroups[0][0]=people[0]

	for i in 0...ncluster
		finalGroups[i] = []
		finalGroups[i].push(people[i*sizeOfCluster])
	end
	finalGroups[ncluster-1][0]=people[peopleNumber-1]

	for x in 0...ncluster
		finalCentroid[x]=finalGroups[x][0]
	end



	assignment=0
	comparisonDist=0
	replacementDist=0


	for i in 0...peopleNumber
		comparisonPoint=people[i]
		for k in 0...ncluster
			comparisonDist=distance(comparisonPoint,finalCentroid[k])
			if(comparisonDist<replacementDist)
				replacementDist=comparisonDist
				assignment=k
			end
		end
		finalGroups[k][finalGroups[k].length]=comparisonPoint
		for o in 0...ncluster
			finalCentroid[o]=centroidCalc(finalGroups[o])
		end

	end

	for i in 0...ncluster
		finalGroups[i].uniq!
	end
	for o in 0...ncluster
			finalCentroid[o]=centroidCalc(finalGroups[o])
		end

	largestCluster=0
	largest=0
	for i in 0...ncluster
		sizeTemp=finalGroups[i].length
		if(largestCluster<sizeTemp)
			largest=i
			sizeTemp=largestCluster
		end
	end

	largestGrouping=finalGroups[largest]
	if personX<0
		multiplier[0]=-1
	end
	if personY<0
		multiplier[1]=-1
	end

	for i in 0...largestGrouping.length
		largestGrouping[i][0]*=multiplier[0]
		largestGrouping[i][1]*=multiplier[1]
	end


	return [finalCentroid[largest],largestGrouping]
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
  # reqs = DB.from(:requests)
  # vendorReqs = reqs.where(:vendor => params["id"])
  # vendorReqs.to_hash.to_json
  Request.filter(:vendor => params["id"].to_i).to_json
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
