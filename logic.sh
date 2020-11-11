#!/bin/bash
#Programmer: Daniel Dolezal
#Write Date: 21.09.2020, 11.11.2020
#Use: Start Spotify when Phone is home and Transfer Playback to PC

SERVICE="spotify"
keyword=is_playing
Computer=$HOSTNAME
configfile=/home/$USER/.config/Spotify_tokens.sh

if [ -z $1 ]; then
#check if Computer is unlocked or locked
dbus-monitor --session "type='signal',interface='org.gnome.ScreenSaver'" |
  while read x; do
    case "$x" in 
      *"boolean true"*) 
      echo SCREEN_LOCKED
      touch /tmp/stopSpotify.txt
      ;;
      *"boolean false"*)
      echo SCREEN_UNLOCKED
      rm -rf /tmp/stopSpotify.txt
      ;;  
    esac
  done
else
 #Make config if not exist
 if [ ! -f $configfile ]; then
  path=$(echo $0 | rev | cut -d "/" -f "2-" | rev)
  sh $path/make_config.sh
 fi
 ##Spotify Variables
 . $configfile
 REDIRECT_URI="http://localhost/"
 #Exist refresh_token?
 if [ ! -z $refresh_token ]; then
  #Get Access Token
  access_token=$(curl -s -d client_id=$CLIENT_ID -d client_secret=$CLIENT_SECRET -d grant_type=refresh_token -d refresh_token=$refresh_token https://accounts.spotify.com/api/token | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])")
  #Loop Checking if Spotify is running or not
  while true; do
   clear
   while [ -f /tmp/stopSpotify.txt ]; do
    echo "Wait for unlock of Computer"
    sleep 10
   done
   if pgrep -x "$SERVICE" >/dev/null; then
    echo "$SERVICE is running"
    playerid=$(curl -s -X "GET" "https://api.spotify.com/v1/me/player" -H "Accept application/json" -H "Authorization: Bearer $access_token" | grep -A 1 "id" | tr "," "\n" | head -n1 | cut -d ":" -f "2")
    #Get Computer ID from Spotify
	if [ -z $ComputerID ]; then
	 ComputerID=$(curl -sS -X "GET" "https://api.spotify.com/v1/me/player/devices" -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $access_token" | python -mjson.tool | grep 'id\|name' | sed 's/"id": //g' | sed 's/"name": //g' | tr "," "\n" | grep -B 2 "$Computer" | head -n1 )
	fi
    if [ ! -z $ComputerID ] && [ $ComputerID != $playerid ]; then
     #Switch Playback to Computer if it play somewhere else
     curl -X "PUT" "https://api.spotify.com/v1/me/player" --data "{\"device_ids\":[$ComputerID]}" -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $access_token"
    fi
   else
    #get if Spotify is Playing on any Device
    api=$(curl -s -X "GET" "https://api.spotify.com/v1/me/player" -H "Authorization: Bearer $access_token" | python3 -c "import sys, json; print(json.load(sys.stdin)['$keyword'])" 2> /dev/null)
    #If Yes run Code
    if [ "$api" == "True" ]; then
     playerid=$(curl -s -X "GET" "https://api.spotify.com/v1/me/player" -H "Accept application/json" -H "Authorization: Bearer $access_token" | grep -A 1 "id" | tr "," "\n" | head -n1 | cut -d ":" -f "2")
     echo "Spotify is playing on other Device start $SERVICE"
     if [ $autologin = 0 ]; then
      $SERVICE & 2> /dev/null
     else
      $SERVICE --username=$spotifyuser --password=$spotifypass &2> /dev/null
     fi
     sleep 5
     #Get Computer ID from Spotify
     ComputerID=$(curl -sS -X "GET" "https://api.spotify.com/v1/me/player/devices" -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $access_token" | python -mjson.tool | grep 'id\|name' | sed 's/"id": //g' | sed 's/"name": //g' | tr "," "\n" | grep -B 2 "$Computer" | head -n1 )
    else
     echo "Spotify is not playing"
     checktoken=$(curl -s -X "GET" "https://api.spotify.com/v1/me/player" -H "Authorization: Bearer $access_token" ) #2> /dev/null)
     checktoken=$(echo $checktoken | cut -d " " -f "5-5" | sed -e 's/,//g')
     #Make new Access Token is old Token is expired
     if [ ! -z $checktoken ] && [ $checktoken == "401" ]; then
      echo "Getting new access_token"
      access_token=$(curl -s -d client_id=$CLIENT_ID -d client_secret=$CLIENT_SECRET -d grant_type=refresh_token -d refresh_token=$refresh_token https://accounts.spotify.com/api/token | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])")
     fi
    fi
   fi
   sleep 10
  done
 else
  echo "Please get refresh_token and add it into /home/$USER/.config/Spotify_tokens.sh" 
 fi
fi
