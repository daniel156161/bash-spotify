# bash-spotify-automate
run spotify when phone is home and play Song

look into requirements.txt for all Programms your Termial neat to work problem-free else command will not get found and nothing will work :(

### EDITs
Config is on /home/$USER/.config/Spotify_tokens.sh
into run.sh edit ping_url= #IP of your Phone

### TO GET CLIENT_ID and CLIENT_SECRET
go to https://developer.spotify.com/dashboard/ add or use a app you like and will see your CLIENT_ID but the CLIENT_SECRET will be hiden click on SHOW CLIENT SECRET to get it then go to the Edit Settings and set the Redirect URIs: to http://localhost/

### GET TOKEN
run ./get_tokens.sh into your terminal
you will get a link and open it into your fav browser

run the code again with the code when your REDIRECT is working

./get_tokens.sh code

then you will have your first access_token and the refresh_token you neat to add into the config file Spotify_tokens.sh
then you neat to add the IP of your Phone or Hostname
