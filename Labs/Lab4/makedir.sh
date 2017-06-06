#!/bin/sh

# directory "constants"
DIR1="personal"
DIR2="professional/courses"
DIR3="professional/societies"

# construct the dirs string containing the path of the directories to be created
dirs="temp "
dirs="$dirs $DIR1/funstuff $DIR1/taxes "
dirs="$dirs $DIR2/general $DIR2/major/cs213 $DIR2/major/cs381/notes $DIR2/major/cs381/labs $DIR2/major/cs381/programs $DIR2/major/cs475 "
dirs="$dirs $DIR3/ieee $DIR3/acm"

# create all directories in 'dirs' variable
mkdir -p  $dirs
