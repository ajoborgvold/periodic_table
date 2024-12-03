#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

MAIN() {

  if [[ -z $1 ]]
  then
    echo Please provide an element as an argument.
    return
  elif [[ $1 =~ ^[0-9]{1,3}$ ]]
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")

    if [[ -z $ATOMIC_NUMBER ]]
    then
      echo I could not find that element in the database.
      return
    fi
  elif [[ $1 =~ ^[A-Za-z]{1,2}$ ]]
  then
    ATOMIC_SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE LOWER(symbol)=LOWER('$1')")

    if [[ -z $ATOMIC_SYMBOL ]]
    then
      echo I could not find that element in the database.
      return

    fi
  elif [[ $1 =~ ^[A-Za-z]+$ ]]
  then
    ATOMIC_NAME=$($PSQL "SELECT name FROM elements WHERE LOWER(name)=LOWER('$1')")

    if [[ -z $ATOMIC_NAME ]]
    then
      echo I could not find that element in the database.
      return
    fi
  fi
  
  if [[ -z $ATOMIC_NUMBER ]]
  then
    if [[ $ATOMIC_SYMBOL ]]
    then
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$ATOMIC_SYMBOL'")
    else
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$ATOMIC_NAME'")
    fi
  fi

  if [[ -z $ATOMIC_SYMBOL ]]
  then
    ATOMIC_SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
  fi
  if [[ -z $ATOMIC_NAME ]]
  then
    ATOMIC_NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
  fi

  TYPE=$($PSQL "SELECT type FROM types INNER JOIN properties USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER")
  MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
  MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number='$ATOMIC_NUMBER'")
  BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number='$ATOMIC_NUMBER'")

  echo "The element with atomic number $ATOMIC_NUMBER is $ATOMIC_NAME ($ATOMIC_SYMBOL). It's a $TYPE, with a mass of $MASS amu. $ATOMIC_NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
}

MAIN $1
