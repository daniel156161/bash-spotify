#!/bin/bash

#Programmer: Daniel Dolezal
#Write Date: 17.02.2020
#Use: Test Switching From Compter to Phone

. /home/$USER/.config/Spotify_tokens.sh
REDIRECT_URI="http://localhost/"

Computer=$HOSTNAME
Phone= #Name into Spotify list_spotify_devices.sh of your Phone

access_token=$(curl -s -d client_id=$CLIENT_ID -d client_secret=$CLIENT_SECRET -d grant_type=refresh_token -d refresh_token=$refresh_token https://accounts.spotify.com/api/token | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])")
  
ComputerID=$(curl -sS -X "GET" "https://api.spotify.com/v1/me/player/devices" -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $access_token" | python -mjson.tool | grep 'id\|name' | sed 's/"id": //g' | sed 's/"name": //g' | tr "," "\n" | grep -B 2 "$Computer" | head -n1 )

PhoneID=$(curl -sS -X "GET" "https://api.spotify.com/v1/me/player/devices" -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $access_token" | python -mjson.tool | grep 'id\|name' | sed 's/"id": //g' | sed 's/"name": //g' | tr "," "\n" | grep -B 2 "$Phone" | head -n1 )

while true; do
echo "Play on Computer"
curl -X "PUT" "https://api.spotify.com/v1/me/player" --data "{\"device_ids\":[$ComputerID]}" -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $access_token"
sleep 10

echo "Play on Phone"
curl -X "PUT" "https://api.spotify.com/v1/me/player" --data "{\"device_ids\":[$PhoneID]}" -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $access_token"
sleep 10
done
