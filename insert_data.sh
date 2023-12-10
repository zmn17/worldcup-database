#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=zamyn17 --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=zamyn17 --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "truncate games, teams")

# reset the id of teams and games
$PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1"
$PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # echo $YEAR, $ROUND, $WINNER, $OPPONENT, $WINNER_GOALS, $OPPONENT_GOALS
  if [[ $YEAR != year ]]
  then
    # get WINNING team_id
    WINNING_TEAM_ID=$($PSQL "select team_id from teams where name = '$WINNER'")
    OPPONENT_TEAM_ID=$($PSQL "select team_id from teams where name = '$OPPONENT'")

    # if winning team id not found
    if [[ -z $WINNING_TEAM_ID ]]
    then
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) values('$WINNER')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted winner $WINNER into teams."
      fi
      #get new winning_team_id
      WINNING_TEAM_ID=$($PSQL "select team_id from teams where name = '$WINNER'")
    fi

    #if opponent team id not found
    if [[ -z $OPPONENT_TEAM_ID ]]
    then
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) values('$OPPONENT')")
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted opponent $OPPONENT into teams."
      fi
      #get new opponent_team_id
      OPPONENT_TEAM_ID=$($PSQL "select team_id from teams where name = '$OPPONENT'")
    fi

    # insert into games
    INSERT_GAME_RESULTS=$($PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values ($YEAR, '$ROUND', $WINNING_TEAM_ID, $OPPONENT_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  fi
done
