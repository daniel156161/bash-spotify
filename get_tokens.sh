#!/bin/bash

#Programmer: Daniel Dolezal
#Write Date: 21.09.2020
#Use: GET Spotify refresh and first access token

. /home/$USER/.config/Spotify_tokens.sh
REDIRECT_URI="http://localhost/"
scopes="user-read-currently-playing,user-read-playback-state,user-modify-playback-state"

CODE=$1

if [ ! -z $CODE ]; then
 curl -sS -d client_id=$CLIENT_ID -d client_secret=$CLIENT_SECRET -d grant_type=authorization_code -d code=$CODE -d redirect_uri=$REDIRECT_URI https://accounts.spotify.com/api/token | python -mjson.tool | grep 'access_token\|refresh_token'
else
 echo 'Open Link: https://accounts.spotify.com/authorize?response_type=code&client_id='$CLIENT_ID'&scope='$scopes'&redirect_uri='$REDIRECT_URI
 echo " "
 echo "input ?code=CODE $0 input_Code_here"
fi

