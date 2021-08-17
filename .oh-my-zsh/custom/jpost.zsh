#!/bin/bash
# About: Bash script to create new Jekyll posts
# Author: @AamnahAkram
# URL: https://gist.github.com/aamnah/f89fca7906f66f6f6a12
# Description: This is a more advanced version of the script which can 
#  - take options
#  - has color coded status messages
#  - improved code
#  - lowercase permalinks 
#  - usage message
#  - opens file in Sublime Text after creation

# VARIABLES
######################################################

# COLORS
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White


function jpost() {

  # VARIABLES
  ###########

  # Define the post directory (where to create the file)
  JEKYLL_POSTS_DIR='/home/nitish/workspace/jadia.dev/_posts/'

  # Post title
    # if more than one argument is provided then TITLE is the last argument
  if [ $# -gt 1 ]; then
    TITLE=${@: -1}
    # if only one argument is provided then it is the Title
  else
    TITLE=$1
  fi

  # Replace spaces in title with underscores
  TITLE_STRIPPED=${TITLE// /_}

  # Permalink
#   PERMALINK=$(tr A-Z a-z <<< $TITLE_STRIPPED)

  # Date
  DATE=`date +%Y-%m-%d`

  # Post Type (markdown, md, textile)
  TYPE='.md'

  # File name structure
  FILENAME=${DATE}-${TITLE_STRIPPED}${TYPE}

  # File path
  FILEPATH=${JEKYLL_POSTS_DIR}${FILENAME}


  # Current date and time
  CURRENT_DATE=`date +"%Y-%m-%d %H:%M %z"`

  # USAGE
  ###########
  showUsage() {
    echo "Usage: jpost -o \"This is my post\" "

  }

  # CREATE POST
  #############
  createPost() {
    # create file
    touch ${FILEPATH}

    # add YAML front matter to the newly created file
    echo -e "---
layout: post
title: ${TITLE}
date: ${CURRENT_DATE}
description: 
tags: [\"Python\"]
image:
  path: \"/assets/social-devops-python-preview.png\"
  width: 1200
  height: 628
twitter:
  card: summary_large_image

---
    " > ${FILEPATH}

    # success message
    echo -e "${Green}File was succesfully CREATED \n
    ${JEKYLL_POSTS_DIR}${FILENAME}${Color_Off}
    "
  }


  # ARGUMENTS
  ###########
  while getopts "o" opt; do
    case $opt in
      o) open=1 ;;
    esac
  done

  # CONDITIONS
  ############
  if [ $# -eq 0 ]; then
    showUsage
  else
    # check if file alreday exists and is not empty
    if [ -s ${FILEPATH} ]; then
      echo -e "${Red}File already EXISTS and is NOT EMPTY${Color_Off}"

    #check if file already exists
    elif [ -e ${FILEPATH} ]; then
      echo -e "${Yellow}File already EXISTS${Color_Off}"

    # check for -o (open) argument
    elif [ ! -z $open ]; then
      createPost
      # Open file in Sublime Text
      open -a "Sublime Text" $FILEPATH

    # if no file with the same name exists, proceed with creating a new one
    else
      createPost
    fi
  fi

}
