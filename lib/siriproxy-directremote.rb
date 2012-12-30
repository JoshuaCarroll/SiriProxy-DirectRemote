require 'cora'
require 'siri_objects'
require 'pp'
require 'open-uri'
require_relative "shef-client.rb"

class SiriProxy::Plugin::DirectRemote < SiriProxy::Plugin

  @@response_wait = [ "Let me see.", "One moment.", "Please hold.", "Just a second.", "Hang on a second.", "Hold on a second.", "Just a moment.", "Give me a second.", "One second." ]

  def initialize(config = {})
    @host = config['host']
  end

  #_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
  listen_for /what is the receiver address/i do
    say "Here is the address of your DirecTV receiver: " + @host + ".", spoken: "Here is the address of your DirecTV receiver."
    request_completed
  end

  #_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
  listen_for /(are there any new shows|is there anything new) on the DVR/i do
    say "I'm not ready for this input yet."
  end

  #_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
  listen_for /record this.*/i do
    client = ShefClient.new(@host)
    client.record
    finishUp(client)
  end

  #_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
  listen_for /pause.*/i do
    client = ShefClient.new(@host)
    client.pause
    finishUp(client)
  end
  
  #_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
  listen_for /play.*/i do
    client = ShefClient.new(@host)
    client.play
    finishUp(client)
  end

  #_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
  listen_for /what (am I|are we) watching/i do
    client = ShefClient.new(@host)
    client.info
    finishUp(client)
  end
  
  #_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
  listen_for /what is this rated/i do
    say @@response_wait[rand(@@response_wait.size)]
    client = ShefClient.new(@host)
    client.getRating
    finishUp(client)
  end
  
  #_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
  listen_for /how much time is left.*/i do
    client = ShefClient.new(@host)
    client.getTimeLeft
    finishUp(client)
  end
  
  #_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
  def finishUp(client)
    say client.displayText, spoken: client.speechText
    request_completed
  end
  
  #_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
#  listen_for /what is.*on channel ([0-9,]*[0-9)/i do |number|
#    html = Net::HTTP.get(URI.parse(rootUrl + '/tv/getProgInfo?major=' + number.to_s()))
#    hash = JSON.parse html
#    if(hash['status']['code'] == 200)
#      words = "\"" + hash["title"] + "\" is on " + hash["callsign"]      
#      if(hash["isRecording"] == true)
#        words += " and it is being recorded to your DVR"
#      end
#      words += "."
#      say words
#    else
#       say "Looks like I can't do that right now."
#    end
#    puts hash
#
#    request_completed
#  end

  #_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
#  listen_for /change the.*channel.*(*[0-9,]*[0-9])/i do |number|
#    say "Detected number: #{number}"
#
#      html = Net::HTTP.get(URI.parse(rootUrl + '/tv/tune?major=' + number.to_s()))
#      hash = JSON.parse html
#      if(hash['status']['code'] == 200)
#        say "Ok."
#      else
#        say "Looks like I can't do that right now."
#      end
#      puts hash
#    request_completed
#  end
  
end


