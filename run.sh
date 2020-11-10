#!/bin/bash

#Programmer: Daniel Dolezal
#Write Date: 21.09.2020
#Use: Start Spotify when Phone is home and Transfer Playback to PC

ping_url= #IP of your Phone
SERVICE="spotify"
keyword=is_playing
Computer= #Name into Spotify list_spotify_devices.sh of your PC

##Spotify
. /home/$USER/.config/Spotify_tokens.sh
REDIRECT_URI="http://localhost/"

if [ ! -z $refresh_token ]; then
 #Get Access Token
 access_token=$(curl -s -d client_id=$CLIENT_ID -d client_secret=$CLIENT_SECRET -d grant_type=refresh_token -d refresh_token=$refresh_token https://accounts.spotify.com/api/token | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])")
 #Loop Checking if Spotify is running or not
 while true; do
  clear
  if pgrep -x "$SERVICE" >/dev/null; then
   echo "$SERVICE is running"
  else
   #Check if Phone is Pingable
   while ! ping -c1 $ping_url 2>/dev/null 1>&2; do sleep 10; done
   #get if Spotify is Playing on any Device
   api=$(curl -s -X "GET" "https://api.spotify.com/v1/me/player" -H "Authorization: Bearer $access_token" | python3 -c "import sys, json; print(json.load(sys.stdin)['$keyword'])" 2> /dev/null)
   #If Yes run Code
   if [ "$api" == "True" ]; then
    echo "Spotify is playing on other Device start $SERVICE"
    $SERVICE & 2> /dev/null
    sleep 10
    #Get Computer ID from Spotify
    ComputerID=$(curl -sS -X "GET" "https://api.spotify.com/v1/me/player/devices" -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $access_token" | python -mjson.tool | grep 'id\|name' | sed 's/"id": //g' | sed 's/"name": //g' | tr "," "\n" | grep -B 2 "$Computer" | head -n1 )
    #Switch Playback to Computer
    curl -X "PUT" "https://api.spotify.com/v1/me/player" --data "{\"device_ids\":[$ComputerID]}" -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $access_token"
   else
    echo "Spotify is not playing"
    checktoken=$(curl -s -X "GET" "https://api.spotify.com/v1/me/player" -H "Authorization: Bearer $access_token" ) #2> /dev/null)
    checktoken=$(echo $checktoken | cut -d " " -f "5-5" | sed -e 's/,//g')
    #Make new Access Token is old Token is expired
    if [ $checktoken == "401" ]; then
     echo "Getting new access_token"
     access_token=$(curl -s -d client_id=$CLIENT_ID -d client_secret=$CLIENT_SECRET -d grant_type=refresh_token -d refresh_token=$refresh_token https://accounts.spotify.com/api/token | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])")
    fi
   fi
  fi
  sleep 10
 done
else
 echo "Please get refresh_token and add it into $0" 
fi
