ping_url= #IP of your Phone
SERVICE="spotify"
keyword=is_playing

##Spotify
. /home/$USER/.config/Spotify_tokens.sh
REDIRECT_URI="http://localhost/"

#Tokens
refresh_token="" #refresh_token got from get_tokens.sh

if [ ! -z $refresh_token ]; then 
 access_token=$(curl -s -d client_id=$CLIENT_ID -d client_secret=$CLIENT_SECRET -d grant_type=refresh_token -d refresh_token=$refresh_token https://accounts.spotify.com/api/token | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])")
 while true; do
  if pgrep -x "$SERVICE" >/dev/null; then
   echo "$SERVICE is running"
  else
   while ! ping -c1 $ping_url 2>/dev/null 1>&2; do sleep 10; done
   api=$(curl -s -X "GET" "https://api.spotify.com/v1/me/player" -H "Authorization: Bearer $access_token" | python3 -c "import sys, json; print(json.load(sys.stdin)['$keyword'])" 2> /dev/null)
   if [ "$api" == "True" ]; then
    echo "Spotify is playing"
    spotify 2> /dev/null
   else
    echo "Spotify is not playing"
    checktoken=$(curl -s -X "GET" "https://api.spotify.com/v1/me/player" -H "Authorization: Bearer $access_token" ) #2> /dev/null)
    checktoken=$(echo $checktoken | cut -d " " -f "5-5" | sed -e 's/,//g')
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