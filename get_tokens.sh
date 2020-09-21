. /home/$USER/.config/Spotify_tokens.sh
REDIRECT_URI="http://localhost/"

echo 'Open Link: https://accounts.spotify.com/authorize?response_type=code&client_id='$CLIENT_ID'&scope=user-read-currently-playing,user-read-playback-state&redirect_uri='$REDIRECT_URI

echo " "
echo "input ?code $0 CODE"


##Get first access_token and refresh_token
if [ ! -z $1 ]; then
 CODE=$1
 curl -d client_id=$CLIENT_ID -d client_secret=$CLIENT_SECRET -d grant_type=authorization_code -d code=$CODE -d redirect_uri=$REDIRECT_URI https://accounts.spotify.com/api/token
fi

