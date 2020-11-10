#!/bin/bash

#Programmer: Daniel Dolezal
#Write Date: 10.11.2020
#Use: GET Spotify list of devices online

. /home/$USER/.config/Spotify_tokens.sh
REDIRECT_URI="http://localhost/"

access_token=$(curl -s -d client_id=$CLIENT_ID -d client_secret=$CLIENT_SECRET -d grant_type=refresh_token -d refresh_token=$refresh_token https://accounts.spotify.com/api/token | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])")

curl -sS -X "GET" "https://api.spotify.com/v1/me/player/devices" -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $access_token"

