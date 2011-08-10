require 'rubygems'
require 'tweetstream'
require 'ratlas'
require 'yajl'
require 'mongo'


db = Mongo::Connection.new.db("watch")
coll = db.collection("tweets")

def listen_to_twitter
  puts "new twitter thread started at #{Time.now}"
  on_tv = []
  Ratlas::Schedule.find(:all).where(:from => Time.now.to_i - 3600, :to=> Time.now.to_i + 3600).and(:channel => 'bbcone', :publisher => 'bbc.co.uk').each do |n|
    n.items.each{|k|
      if k.brand_summary
        on_tv << [k.brand_summary.title.downcase, k.uri]
      else
        on_tv << [k.title.downcase, k.uri]
      end
    }
    
  end
  
  puts on_tv.inspect
  TweetStream::Client.new('14watching', 'password100', :yajl).track(on_tv.map{|n| n.first}.join(',')) do |status|
    puts status.text
    found_show = on_tv.select{|s| status.text.downcase.include?(s.first)}
    unless found_show.empty?
      atlas_show =  Ratlas::Content.find(:all).where(:uri => found_show.first[1]).to_a.first
      saved_resource = {
        :tweet_text => status.text, :tweet_username => status[:user][:screen_name], :tweet_display_picture => status[:user][:profile_image_url],
        :show_title => found_show.first[0], :show_description => atlas_show.description, :show_image => atlas_show.image, :show_url => found_show.first[1],
        :time => Time.now
      }
      puts saved_resource.inspect
      coll.insert(saved_resource)
    end
  end
end






client_thread = Thread.new do
  listen_to_twitter
end

timing_thread = Thread.new do
  while true
    puts "starting timing thread"
    sleep(60*15)
    puts "Timing thread awake and killing client"
    client_thread.kill
    client_thread = Thread.new do
      listen_to_twitter
    end
  end
end
timing_thread.join




