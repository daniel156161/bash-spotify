#!/bin/bash

#Programmer: Daniel Dolezal
#Write Date: 11.11.2020
#Use: Run all probably

path=$(echo $0 | rev | cut -d "/" -f "2-" | rev)
sh $path/logic.sh &
sh $path/logic.sh 1
