#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

GET_ELEMENT_DETAILS(){
  # Needed details:
  # - symbol
  # - name
  # - type
  # - atomic_mass
  # - melting_point_celsius
  # - boiling_point_celsius
  
  ELEMENT_DETAILS=$($PSQL "SELECT symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM elements LEFT JOIN properties USING(atomic_number) LEFT JOIN types USING(type_id) WHERE atomic_number=$1")
  
  if [[ -z $ELEMENT_DETAILS ]]
  then
    echo -e "\nERROR: Details of '$1' element not found. Database might be altered!\n"
  else
    #echo "$ELEMENT_DETAILS"
    DETAILS_WITH_SPACES_INSTEAD_OF_BARS=${ELEMENT_DETAILS//'|'/' '}
    echo "$DETAILS_WITH_SPACES_INSTEAD_OF_BARS" | while read SYMBOL NAME ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE
    do
      #echo -e "\n~~~~ Element details: ~~~~\n"
      #echo -e "Atomic number: $1"
      #echo -e "Symbol: $SYMBOL"
      #echo -e "Name: $NAME"
      #echo -e "Type: $TYPE"
      #echo -e "Atomic mass: $ATOMIC_MASS amu"
      #echo -e "Melting point in Celsius: $MELTING_POINT"
      #echo -e "Boiling point in Celsius: $BOILING_POINT"
      
      echo "The element with atomic number $1 is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  fi
}

CHECK_IF_ELEMENT_EXISTS_IN_DATABASE(){
  if [[ -z $1 ]]
  then
    echo -e "Please provide an element as an argument."
  else
    if [[ $1 =~ ^[0-9]+$ ]]
    then
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")
    else
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1'")

      if [[ -z $ATOMIC_NUMBER ]]
      then
        ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$1'")
      fi
    fi
    
    if [[ -z $ATOMIC_NUMBER ]]
    then
      echo -e "I could not find that element in the database."
    else
      #echo -e "\nElement with atomic number '$ATOMIC_NUMBER' found!\n"
      GET_ELEMENT_DETAILS $ATOMIC_NUMBER
    fi
  fi
}

ARGUMENT=$1
CAPITALIZED_ARGUMENT="${ARGUMENT^}"
CHECK_IF_ELEMENT_EXISTS_IN_DATABASE $CAPITALIZED_ARGUMENT
