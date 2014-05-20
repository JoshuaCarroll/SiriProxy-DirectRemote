SiriProxy-DirectRemote
======================

A SiriProxy plugin that enables Siri to control your DirecTV receiver.

This plugin is for use with @plamoni's SiriProxy.  It will allow the user to give Siri commands to send to your DirecTV receiver.  For example, you can say "What am I watching?", and Siri will reply with the name of the program you are watching and the channel it is on.

This is my first open-source project, and is some of my first work with Ruby.

Setup
=====

The only setup required is to set the value of the host variable in the config file.  This is the IP address of the DirecTV receiver that you want to associate with the plugin.

Copy the contents of `config-info.yml` into your `~/.siriproxy/config.yml`.  Edit the config.yml so that the `host` value reflects the IP address of your receiver.  Your `config.yml` file should now look similar to this example, but will have your receiver's IP address as the host value:

```
name: 'DirectRemote'
git: 'git://github.com/JoshuaCarroll/SiriProxy-DirectRemote.git'
host: '192.168.1.100'
```

Then run `rvmsudo siriproxy update` from the console. Then just start SiriProxy by running `rvmsudo siriproxy server`

Requirements/Components
=======================

1. SiriProxy server
2. DirecTV receiver (see note)

Note: DIRECTV high-definition set-top box models H21, HR20 and newer; other models are not supported. While most DirecTV receivers that are capable of connecting to your LAN or WLAN have the required components to receive and process requests through Set-top box HTTP Exported Functionality (SHEF), I do not know if your particular model will do.  It is up to you to see if your receiver has this capability.

Usage
=====

Currently there are a limiated number of commands/questions that you can use with the SiriProxy-DirectRemote. Those include:

*  What is the receiver address?
*  Are there any new shows on the DVR?
*  Is there anything new on the DVR?
*  Record This
*  Pause
*  Play
*  What am I watching?
*  What are we watching?
*  What is this rated?
*  How much time is left?
  
Many of these commands have wildcards in them to allow for normal speech patterns.  For example, to call the `How much time is left` command, one could say `How much time is left in this show` or `How much time is left in the movie we are watching`.


Licensing
=========

Re-use of my code is fine under a Creative Commons 3.0 [Non-commercial, Attribution, Share-Alike](http://creativecommons.org/licenses/by-nc-sa/3.0/) license. In short, this means that you can use my code, modify it, do anything you want. Just don't sell it and make sure you let me know. Also, you must license your derivatives under a compatible license (sorry, no closed-source derivatives). If you would like to purchase a more permissive license (for a closed-source and/or commercial license), please contact me directly. See the Creative Commons site for more information.

Disclaimer
==========

Apple
-----
I am not affiliated with Apple in any way. They don't endorse this application. They own all the rights to Siri (and all associated trademarks). This software is provided as-is with no warranty whatsoever. Apple could do things to block this kind of behavior if they want. I'm a huge fan of Apple and the work that they do. Siri is a very cool feature and I'm pretty excited to explore it and add functionality. Please refrain from using this software for anything malicious.

DirecTV
-------
I am not affiliated with DirecTV in any way.  Their disclaimer for using the SHEF interface reads as follows:

    DIRECTV makes no representations or warranties, express or implied, that use of the technologies 
    described in this specification will not infringe patents, copyrights, or other intellectual property 
    rights of third parties. Nothing in this specification should be construed as granting permission to 
    use any of the technologies described. Anyone planning to make use of technology covered by the 
    intellectual property rights of others should first obtain permission from the holder(s) of the rights. 
    This specification is subject to change without notice. DIRECTV does not accept any responsibility 
    whatsoever for any damages or liability, direct or consequential, which may result from use of this 
    specification or any related discussions.  These specifications are provided “as is” and the user of 
    these specifications assumes any and all risks associated with the use of these specifications.  
    DIRECTV expressly disclaims any and all representations or warranties, express or implied, 
    regarding the specifications, including without limitation any warranty as to merchantability, fitness 
    for a particular purpose, non-interruption of use, or non-infringement.

So, just to sum it up... You are authorized to use this software under the Wil Wheaton License.  (That means you can use it, as long as you don't use it to be a dick.)
