require 'cora'
require 'siri_objects'
require 'pp'
require 'open-uri'
require_relative "shef-client.rb"

class SiriProxy::Plugin::DirectRemote < SiriProxy::Plugin

  def initialize(config = {})
    @host = config['host']
  end

#---------------------------------------------------------------------
  listen_for /what is the receiver address/i do
    say "Here is the address of your DirecTV receiver: " + @host + ".", spoken: "Here is the address of your DirecTV receiver."
    
    request_completed
  end

#---------------------------------------------------------------------
  listen_for /(are there any new shows|is there anything new) on the DVR/i do
    say "I'm not ready for this input yet."
  end

#---------------------------------------------------------------------
  listen_for /record this.*/i do
    client = ShefClient.new(@host)
    client.record
    
    say client.displayText, spoken: client.speechText
    
    request_completed
  end


#---------------------------------------------------------------------
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



#---------------------------------------------------------------------
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

#---------------------------------------------------------------------
  listen_for /pause.*/i do
    client = ShefClient.new(@host)
    client.pause
    
    say client.displayText, spoken: client.speechText
    
    request_completed
  end
  
#---------------------------------------------------------------------
  listen_for /play.*/i do
    client = ShefClient.new(@host)
    client.play
    
    say client.displayText, spoken: client.speechText
    
    request_completed
  end

#---------------------------------------------------------------------
  listen_for /what (am I|are we) watching/i do
      html = Net::HTTP.get(URI.parse(rootUrl + '/tv/getTuned?clientAddr=0'))
      hash = JSON.parse html
      if(hash['status']['code'] == 200)
        @words = "You are watching \"" + hash['title'] + "\" "
        if(hash['isViewed'])
          @words += "on the DVR."
        else
          @words += "on " + hash['callsign'] + ", channel " + hash['major'].to_s() + "."
        end
        say @words
      else 
        if(hash['status']['code'] == 403)
          say "It appears I don't have access to that information. You can grant me access to what you are currently viewing by opening the menu on your DirecTV receiver, and changing the Whole-Home settings."
        else
          say "I can't get that information right now, sorry."
        end
      end
      puts hash
    request_completed
  end
  
end


