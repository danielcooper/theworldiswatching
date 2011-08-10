require 'sinatra'
require 'mongo'

get '/' do
  db = Mongo::Connection.new.db("watch")
  coll = db.collection("tweets")
  @tweets = coll.find({}, {:sort => ['time', :desc]}).limit(4).to_a
  erb :index
end

get '/before/:time' do |seconds|
  time = Time.at(seconds.to_i)
  db = Mongo::Connection.new.db('watch')
  coll = db.collection('tweets')
  @tweets = coll.find({'time' => {'$lt' => time}}, {:sort => ['time', :desc]}).limit(4).to_a
  unless @tweets.empty?
  erb :paging, :layout => false
  else 
    "none"
  end
end

get '/after/:time' do  |seconds|
  time = Time.at(seconds.to_i)
  db = Mongo::Connection.new.db('watch')
  coll = db.collection('tweets')
  @tweets = coll.find({'time' => {'$gt' => time+1}}, {:sort => ['time', :asc]}).limit(4).to_a.reverse
  unless @tweets.empty?
    erb :paging, :layout => false 
  else 
    "none"
  end
end