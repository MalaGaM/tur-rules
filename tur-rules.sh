#!/bin/bash
VER=1.1
by SiCiaTeCh
##CONFIG PART#########################
glroot=/glftpd
rules=/ftp-data/misc/site.rules
compress=" "
sections="
MP3:^10.
GENERAL:^01.
"

######################################################
# No changes below here. Can change the "echo" parts #
# if you like though.                                #
######################################################

IsGL="1"
## Can we read the rules file ?
if [ ! -r $rules ]; then
  rules=$glroot/$rules
  if [ ! -r $rules ]; then
    echo "Cant read rules file. Check path and permissions."
    exit 0
  else
      IsGL=0
  fi
fi

## Procedure for listing all defined sections.
proc_listsections() {
  for section in $sections; do
    name="$( echo $section | cut -d':' -f1 )"
    if [ "$names" ]; then
      names="$names $name"
    else
      names="$name"
    fi
  done
  echo "SiCiaTeCh-Rules $VER."
  if [ $IsGL ]; then
    echo "Usage: site rules <section> (searchword)"
  else
    echo "Usage: !rules <section> (searchword)"
  fi
  echo "Defined sections are: $names"
    if [ $IsGL ]; then
    echo "Usage: site rules $name limited"
  else
    echo "Example !rules $name limited"
  fi
  
}


## If no argument, run the above proc.
if [ -z "$1" ]; then
  proc_listsections
  exit 0
fi

## Got inputs correct. Lets go searching.
for section in $sections; do

  ## Grab section name from data.
  name="$( echo $section | cut -d':' -f1 )"

  ## Check if this section is what the user asked for..
  if [ "$( echo $name | grep -wi "^$1$" )" ]; then
    
    ## Get the searchwords defined for this section. 
    search="$( echo $section | cut -d':' -f2 | tr -s '|' ' ' )"

    ## Add each searchword up, adding a ^ infront.
    for each in $search; do
      if [ "$searchline" ]; then
        searchline="^$each|$searchline"
      else
        searchline="^$each"
      fi
    done

    ## Do a different search if a searchword was included.
    if [ "$2" ]; then
      if [ "$compress" ]; then
        ## If we have something to compress...
        OUTPUT="$( egrep $searchline $rules | grep -i "$2" | tr -s "$compress" | tr -s ' ' '^' )"
      else
        ## If compress is ""
        OUTPUT="$( egrep $searchline $rules | grep -i "$2" | tr -s ' ' '^' )"
      fi
      msg=", containing '$2'"
    else
      if [ "$compress" ]; then
        ## If we have something to compress...
        OUTPUT="$( egrep $searchline $rules | tr -s "$compress" | tr -s ' ' '^' )"
      else
        ## If compress is ""
        OUTPUT="$( egrep $searchline $rules | tr -s ' ' '^' )"
      fi
    fi

    ## Output the text we found.
    if [ "$OUTPUT" ]; then
      echo "Rules for section $name$msg:"
      for each in $OUTPUT; do
        echo $each | tr -s '^' ' '
      done
    fi

    ## Set GOTONE so we know we found a section.
    GOTONE="TRUE"

  fi
done

## User did not enter a defined section.
if [ -z "$GOTONE" ]; then
  proc_listsections
  exit 0
fi

## User entered a defined section but no rules found.
if [ -z "$OUTPUT" ]; then
  echo "No rule found so... its allowed !!"
  exit 0
fi

exit 0
