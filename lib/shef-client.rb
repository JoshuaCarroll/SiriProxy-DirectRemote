require 'json'

class ShefClient
  attr_accessor :responseCode, :responseDescription, :speechText, :displayText, :title, :isViewed, :callsign, :channel, :isPpv, :isRecording, 
    :rating, :duration, :offset, :minutesLeft

  # Siri responses 
  @@response_wait = [ "One moment.", "Please hold.", "Just a second.", "Hang on a second.", "Hold on a second.", "Just a moment.", "Give me a second.", "One second." ]
  @@response_ok = [ "No problem.", "Okay.", "Sure.", "Okey dokey." ]
  @@response_watch = [ "Would you like to watch it?", "Want me to change the station for you?", "Should I change the channel for you?" ]
  @@response_error = [ "Something went wrong.", "Ouch! Something broke.", "Sorry, it's not working.", "Um, yeah, that didn't work." ]

  #_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
  def initialize(hostAddress)    
    @rootUrl = "http://" + hostAddress + ":8080"
  end

  #_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
  def request(commandRelativeURL)
  
    htmlResponse          = Net::HTTP.get(URI.parse(@rootUrl + commandRelativeURL))
    json                  = JSON.parse htmlResponse
    self.responseCode     = json['status']['code']
    self.title            = json['title'].to_s()
    self.callsign         = json['callsign'].to_s()
    self.isViewed         = json['isViewed']
    self.channel          = json['major'].to_s()
    self.isPpv            = json['isPpv']
    self.isRecording      = json['isRecording']
    self.rating           = json['rating'].to_s()
    self.duration         = json['duration']
    self.offset           = json['offset']
    self.minutesLeft      = self.duration.nil? || self.offset.nil? ? 0 : ((self.duration - self.offset) / 60).round
    
    
    self.responseDescription = case self.responseCode
      when 200 then "Ok"
      when 400 then "Bad Request. The request contains malformed syntax.  The request should not be resent."
      when 403 then "Forbidden. The server understood the request but is refusing to fulfill it."
      when 409 then "Conflict. The request could not be completed due to a conflict with resources.  The user might be able to resolve the conflict and resubmit the request."
      when 500 then "Internal Server Error The server encountered an unexpected condition.  The request cannot be fulfilled."
      when 503 then "Service Unavailable. The server is currently unable to handle the request due to a temporary overloading of the server.  This is a temporary condition that should be resolved after some delay."
      when 505 then "HTTP Version Not Supported. The server does not support the HTTP protocol version of the request message."
      else "Unrecognized response received."
    end
    
    if(self.responseCode == 200)
      respond 'ok'
    else
      respond 'error'
      self.displayText += self.responseDescription
    end
  end
  
  #_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
  def respond(r)
    responseText = case r
      when 'wait' then @@response_wait[rand(@@response_wait.size)]
      when 'ok' then @@response_ok[rand(@@response_ok.size)]
      when 'watch' then @@response_watch[rand(@@response_watch.size)]
      when 'error' then @@response_error[rand(@@response_error.size)]
      else 'You are doing it wrong.'
    end
    
    self.speechText = responseText
    self.displayText = self.speechText
  end

  #_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
  def test
    request '/tv/getTuned?clientAddr=0'
  end
  
  #_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
  def record
    request '/remote/processKey?key=record'
    
    if(self.responseCode == 200)
      request '/remote/processKey?key=select'
      request '/remote/processKey?key=select'
    end
  end
  
  #_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
  def pause
    request '/remote/processKey?key=pause'
  end
  
  #_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
  def play
    request '/remote/processKey?key=play'
  end
  
  #_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
  def info
    request '/tv/getTuned?clientAddr=0'
    
    if(self.responseCode == 200)
      self.speechText = "You are watching \"" + self.title + "\" "
      if(self.isViewed)
        self.speechText += "on the DVR."
      else
        if(self.isPpv)
          self.speechText += "on pay-per-view."
        else
          self.speechText += "on " + self.callsign + ", channel " + self.channel
          if (self.isRecording)
            self.speechText += ", and it is being recorded to your DVR."
          else
            self.speechText += "."
          end
        end
      end
    else 
      if(self.responseCode == 403)
        self.speechText = "It appears I don't have access to that information. You can grant me access to what you are currently viewing by opening the menu on your DirecTV receiver, and changing the Whole-Home settings."
      end
    end
    self.displayText = self.speechText
  end
  
  #_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
  def getRating
  
    request '/tv/getTuned?clientAddr=0'

    self.speechText = "'" + self.title + "' is rated " + self.rating + "."
    self.displayText = self.speechText
  end
  
  #_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
  def getTimeLeft
    request '/tv/getTuned?clientAddr=0'
    
    self.speechText = "There "
    if (self.minutesLeft > 1)
      self.speechText += "are " + self.minutesLeft.to_s() + " minutes "
    else
      self.speechText += " is 1 minute "
    end
    self.speechText += "left in this "
    if (self.duration <= 3600)
      self.speechText += "episode."
    else
      self.speechText += "movie."
    end
    
    self.displayText = self.speechText
  end
  
end


