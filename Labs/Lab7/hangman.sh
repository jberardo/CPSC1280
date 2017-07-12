#!/bin/bash

letters=({a..z})
guessedLetters=()
word="---"
correctWord=bus
counter=0

main()
{
#	echo "First array: " ${letters[@]}
#	echo "Second array: " ${guessedLetters[@]}
  show_header

  show_word

  echo ${guessedLetters[@]}

 read_letter
 
 check_answer

  #clear
}

show_header()
{
  echo "-----------------"
  echo "Hangman V0.1 BETA"
  echo "-----------------"
}

show_word()
{
  
  echo $word
}

read_letter()
{
  local guess
  read -p "> " guess

  echo $guess

  guessedLetters[$counter]=$guess

  contains $correctWord $guess
  echo "Contains $?"

  ((counter++))
}

contains()
{
  local e
  for e in $1; do echo $e; [[ $e == $2 ]] && return 0; done
  return 1
}

check_answer()
{
  echo "oi"
}

while :
do
  main
done
