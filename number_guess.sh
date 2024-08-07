#!/bin/bash

#PSQL variable
PSQL="psql --username=freecodecamp --dbname=guessing_game_users -t --no-align -c"

#Generate random number
TARGET=$(($RANDOM % 1000 + 1))
#Get username (up to 22 char)
echo "Enter your username:"
read USERNAME
USERDATA=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME'")
if [[ -z $USERDATA ]] #If new user
then
  CREATE_NEW_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 10000)")
  GAMES_PLAYED=0
  BEST_GAME=10000
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else #If previous user
  IFS='|' read -r USERNAME GAMES_PLAYED BEST_GAME <<< "$USERDATA"
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#Prompt for and read guess
echo -e "\nGuess the secret number between 1 and 1000:"
NUMBER_OF_GUESSES=0
while true
do
  read GUESS
  NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
  #If improper input
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"

  #Correct guess
  elif [[ $GUESS == $TARGET ]]
  then
    echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $TARGET. Nice job!\n"
    break
  #Too high
  elif [[ $GUESS -lt $TARGET ]]
  then
    echo -e "\nIt's higher than that, guess again:"

  #Too low
  else
    echo -e "\nIt's lower than that, guess again:"

  fi
done
GAMES_PLAYED=$(($GAMES_PLAYED + 1))

#Update user in database
if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
then
  BEST_GAME=$NUMBER_OF_GUESSES
fi
UPDATED_USER_INFO=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'")
