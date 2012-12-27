require 'cora'
require 'siri_objects'
require 'pp'
require 'open-uri'
require 'json'

#######
# Remember to add other plugins to the "config.yml" file if you create them!
######

class SiriProxy::Plugin::DirectRemote < SiriProxy::Plugin
  attr_accessor :host, :rootUrl

  def initialize(config = {})
    self.host = config['host']
    self.rootUrl = "http://" + config['host'] + ":8080"
		
    # Siri responses - Not yet implemented
    #@responses_wait = [ "One moment.", "Please hold.", "Just a second, please." ]
    #@responses_ok = [ "No problem.", "Okay.", "Sure.", "Not a problem.", "Sure thing.", "You got it." ]
    #@response_error = [ "Something went wrong.", "Looks like I can't do that right now.", "Sorry, something is not working." ]
  end
  
  def ProcessResponse(jsonResponse)
    responseCode = jsonResponse['status']['code']
    
    result = case responseCode
      when 200 then "Ok"
      when 400 then "Bad Request. The request contains malformed syntax.  The request should not be resent."
      when 403 then "Forbidden. The server understood the request but is refusing to fulfill it."
      when 409 then "Conflict. The request could not be completed due to a conflict with resources.  The user might be able to resolve the conflict and resubmit the request."
      when 500 then "Internal Server Error The server encountered an unexpected condition.  The request cannot be fulfilled."
      when 503 then "Service Unavailable. The server is currently unable to handle the request due to a temporary overloading of the server.  This is a temporary condition that should be resolved after some delay."
      when 505 then "HTTP Version Not Supported. The server does not support the HTTP protocol version of the request message."
      else "Unrecognized response received."
    end

    puts result
  end

#---------------------------------------------------------------------
  listen_for /what is the receiver address/i do
    say "Here is the address of your DirecTV receiver: " + host + ".", spoken: "Here is the address of your DirecTV receiver."
  end

#---------------------------------------------------------------------
  listen_for /(are there any new shows|is there anything new) on the DVR/i do
    say "I'm not ready for this input yet."

    response = ask "Would you like me to display your DVR queue on the TV?" #ask the user for something

    if(response =~ /yes/i) #process their response
      html = Net::HTTP.get(URI.parse(rootUrl + '/remote/processKey?key=list'))
      say "There you are."
    else
      say "Ok."
    end

    request_completed
  end

#---------------------------------------------------------------------
  listen_for /record this.*/i do
      html = Net::HTTP.get(URI.parse(rootUrl + '/remote/processKey?key=record'))
      hash = JSON.parse html
      if(hash['status']['code'] == 200)
        html = Net::HTTP.get(URI.parse(rootUrl + '/remote/processKey?key=select'))
        html = Net::HTTP.get(URI.parse(rootUrl + '/remote/processKey?key=select'))
        say "Ok."
      else
        say "Looks like I can't do that right now."
      end
      puts hash
    request_completed
  end


#---------------------------------------------------------------------
  listen_for /what is.*on channel ([0-9,]*[0-9,]*[0-9)/i do |number|
    html = Net::HTTP.get(URI.parse(rootUrl + '/tv/getProgInfo?major=' + number.to_s()))
    hash = JSON.parse html
    if(hash['status']['code'] == 200)
      words = "\"" + hash["title"] + "\" is on " + hash["callsign"]      
      if(hash["isRecording"] == true)
        words += " and it is being recorded to your DVR"
      end
      words += "."
      say words
    else
       say "Looks like I can't do that right now."
    end
    puts hash

    request_completed
  end



#---------------------------------------------------------------------
  listen_for /change the.*channel.*([0-9,]*[0-9,]*[0-9])/i do |number|
    say "Detected number: #{number}"

      html = Net::HTTP.get(URI.parse(rootUrl + '/tv/tune?major=' + number.to_s()))
      hash = JSON.parse html
      if(hash['status']['code'] == 200)
        say "Ok."
      else
        say "Looks like I can't do that right now."
      end
      puts hash
    request_completed
  end

#---------------------------------------------------------------------
  listen_for /pause.*/i do
      html = Net::HTTP.get(URI.parse(rootUrl + '/remote/processKey?key=pause'))
      hash = JSON.parse html
      if(hash['status']['code'] == 200)
        say "Ok"
      else
        say "Looks like I can't do that right now."
      end
      puts hash
    request_completed
  end
  
#---------------------------------------------------------------------
  listen_for /play/i do
      html = Net::HTTP.get(URI.parse(rootUrl + '/remote/processKey?key=play'))
      hash = JSON.parse html
      if(hash['status']['code'] == 200)
        say "Ok"
      else
        say "Looks like I can't do that right now."
      end
      puts hash
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
