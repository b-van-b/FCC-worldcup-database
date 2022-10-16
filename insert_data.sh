#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# clear data
echo "$($PSQL "TRUNCATE TABLE games, teams")"

# set file name
if [[ $1 == "fast" ]]
then
  CSV="games_test.csv"
else
  CSV="games.csv"
fi

# read in file
# year,round,winner,opponent,winner_goals,opponent_goals
cat $CSV | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # skip the column headers
  if [[ $YEAR == "year" ]]
  then
    continue
  fi

  # debug
  echo $YEAR $ROUND $WINNER $OPPONENT $WINNER_GOALS $OPPONENT_GOALS

  # find winner ID
  RESPONSE="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
  # if not exist:
  if [[ -z $RESPONSE ]]
  then
    # add team
    echo "$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")"
    # get new team ID
    RESPONSE="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
  fi
  WINNER_ID=$RESPONSE
  
  # find opponent ID
  RESPONSE="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
  # if not exist:
  if [[ -z $RESPONSE ]]
  then
    # add team
    echo "$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")"
    # get new team ID
    RESPONSE="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
  fi
  OPPONENT_ID=$RESPONSE

  # add new game record
  echo "$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES('$YEAR','$ROUND','$WINNER_ID','$OPPONENT_ID','$WINNER_GOALS','$OPPONENT_GOALS')")"
done