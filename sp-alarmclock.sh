#!/bin/bash
#Programmer: Daniel Dolezal
#Write Date: 21.09.2020, 11.11.2020
#Use: Start Spotify when Phone is home and Transfer Playback to PC

SERVICE="spotify"
keyword=is_playing
Computer=$HOSTNAME
configfile=/home/$USER/.config/Spotify_tokens.sh

#Make config if not exist
if [ ! -f $configfile ]; then
 path=$(echo $0 | rev | cut -d "/" -f "2-" | rev)
 sh $path/make_config.sh
fi
##Spotify Variables
. $configfile
REDIRECT_URI="http://localhost/"

#SET Variables
time=$(date +%H%M)
datum=$(date +%d)

#Start of Alarm
startdatum=$(date +%d)

alarm=0630
toplay=spotify:playlist:3QxGISfwWOVO6QtGkn3NqU #One of My Playlists

if [ ! -z $refresh_token ]; then
 #Get Access Token
 access_token=$(curl -s -d client_id=$CLIENT_ID -d client_secret=$CLIENT_SECRET -d grant_type=refresh_token -d refresh_token=$refresh_token https://accounts.spotify.com/api/token | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])")
 while true; do
  clear
  #get if Spotify is Playing on any Device
  api=$(curl -s -X "GET" "https://api.spotify.com/v1/me/player" -H "Authorization: Bearer $access_token" | python3 -c "import sys, json; print(json.load(sys.stdin)['$keyword'])" 2> /dev/null)
  if [ -z "$api" ]; then
   while [ $time -lt $alarm ] || [ $startdatum -ge $datum ]; do
    clear
    echo "$time | Wait for the Time is up"
    sleep 10
    time=$(date +%H%M)
    datum=$(date +%d)
   done
  fi
  if pgrep -x "$SERVICE" >/dev/null; then
   echo "$SERVICE is running"
   #Switch Playback to Computer if it play somewhere else
   api=$(curl -s -X "GET" "https://api.spotify.com/v1/me/player" -H "Authorization: Bearer $access_token" | python3 -c "import sys, json; print(json.load(sys.stdin)['$keyword'])" 2> /dev/null)
   if [ "$api" != "True" ]; then
    curl -X "PUT" "https://api.spotify.com/v1/me/player/play?device_id=a67cd41a3820112fc92474b7c47a9bd752dc32de" --data "{\"context_uri\":\"$toplay\",\"position_ms\":0}" -H "Accept:  application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $access_token"
    sleep 0.2
    curl -X "PUT" "https://api.spotify.com/v1/me/player/shuffle?state=true" -H "Authorization: Bearer $access_token" && curl -X "POST" "https://api.spotify.com/v1/me/player/next" -H "Authorization: Bearer $access_token"
   fi
   if [ -f /tmp/stopspotifyalarm.txt ]; then
    curl -X "PUT" "https://api.spotify.com/v1/me/player/shuffle?state=false" -H "Authorization: Bearer $access_token"
    pkill -f spotify
    startdatum=$(date +%d)
    rm -rf /tmp/stopspotifyalarm.txt
   fi
  else
   #If Yes run Code
   echo "Spotify is not running"
   if [ -z $autologin ]; then
    $SERVICE & 2> /dev/null
   else
    $SERVICE --username=$spotifyuser --password=$spotifypass & 2> /dev/null
   fi 
  fi
  checktoken=$(curl -s -X "GET" "https://api.spotify.com/v1/me/player" -H "Authorization: Bearer $access_token" ) #2> /dev/null)
  checktoken=$(echo $checktoken | cut -d " " -f "5-5" | sed -e 's/,//g')
  #Make new Access Token is old Token is expired
  if [ ! -z $checktoken ] && [ $checktoken == "401" ]; then
   echo "Getting new access_token"
   access_token=$(curl -s -d client_id=$CLIENT_ID -d client_secret=$CLIENT_SECRET -d grant_type=refresh_token -d refresh_token=$refresh_token https://accounts.spotify.com/api/token | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])")
  fi
  sleep 10
 done
else
 echo "Please get refresh_token and add it into /home/$USER/.config/Spotify_tokens.sh" 
fi
