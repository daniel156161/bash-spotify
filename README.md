# bash-spotify-automate
run spotify when phone is coming home, play Song and switch Playback to PC

look into requirements.txt for all Programms your Termial neat to work problem-free else command will not get found and nothing will work :(

### EDITs
into run.sh you only neat to edit ping_url= with the IP of your Phone or Hostname

### TO GET CLIENT_ID and CLIENT_SECRET
go to https://developer.spotify.com/dashboard/ add or use a app you like and you will see your CLIENT_ID but the CLIENT_SECRET will be hidden click on SHOW CLIENT SECRET to get it then go to the Edit Settings and set the Redirect URIs: to http://localhost/ thats all what you neat here

### GET TOKEN
run ./make_config.sh to make the config file at /home/$USER/.config/Spotify_tokens.sh and folow the instructions of the Skript

### Done
after that you can run ./run.sh and all should working nicely :3 and you can have fun with it
