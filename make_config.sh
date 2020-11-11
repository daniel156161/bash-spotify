#!/bin/bash
#Programmer: Daniel Dolezal
#Write Date: 11.11.2020
#Use: Make configfile and GET Spotify refresh and first access token

configfile=/home/$USER/.config/Spotify_tokens.sh
REDIRECT_URI="http://localhost/"
scopes="user-read-currently-playing,user-read-playback-state,user-modify-playback-state"

if [ -f $configfile ]; then
 read -p 'Config file exist do you like to overright it? [Y/N]: ' configfile_exist
 if [ $configfile_exist = Y ] || [ $configfile_exist = y ]; then
  rm -rf $configfile
 else
  exit
 fi
fi

read -p 'What is your CLIENT_ID: ' CLIENT_ID
read -p 'What is your CLIENT_SECRET: ' CLIENT_SECRET
read -p 'Do you have already a Refresh Token? [Y/N]: ' refresh_token_exist
echo "CLIENT_ID=$CLIENT_ID">>$configfile
echo "CLIENT_SECRET=$CLIENT_SECRET">>$configfile
 
if [ $refresh_token_exist = Y ] || [ $refresh_token_exist = y ]; then
 read -p 'What is your Refresh Token: ' refresh_token
 echo "refresh_token=$refresh_token">>$configfile
 echo "Make Config Successful, All is now ready for you :3" 
elif [ $refresh_token_exist = N ] || [ $refresh_token_exist = n ]; then
 echo 'Open Link: https://accounts.spotify.com/authorize?response_type=code&client_id='$CLIENT_ID'&scope='$scopes'&redirect_uri='$REDIRECT_URI
 read -p 'Input Redirect URL here (http://localhost/?code=): ' refresh_token_url
 url=$(echo $refresh_token_url | cut -d "/" -f "-3")
 while [ "$url" != "http://localhost" ] ; do
  echo "Wrong URL address"
  read -p 'Input Redirect URL here (http://localhost/?code=): ' refresh_token_url
  url=$(echo $refresh_token_url | cut -d "/" -f "-3")
 done
 first_access_token=$(echo $refresh_token_url | cut -d "=" -f "2")
 refresh_token=$(curl -sS -d client_id=$CLIENT_ID -d client_secret=$CLIENT_SECRET -d grant_type=authorization_code -d code=$first_access_token -d redirect_uri=$REDIRECT_URI https://accounts.spotify.com/api/token | python -mjson.tool | grep 'refresh_token' | sed 's/"refresh_token": //g' | sed 's/,//g' )
 echo "refresh_token=$refresh_token">>$configfile
 sed -i 's/    //g' $configfile
 echo "Make Config Successful, All is now ready for you :3"
else
 echo "Only Y or N please!"
fi

