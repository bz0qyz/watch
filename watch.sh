#!/bin/bash
#
# Author: bz0qyz
# Repository: https://github.com/bz0qyz/watch

app_name='watch'

# Set the deafult wait time
WAIT=5
LOOP=0

txtnone='\033[0m' # no color
txtblk='\e[0;30m' # Black - Regular
txtred='\033[0;31m' # Red
txtgrn='\033[0;32m' # Green
txtylw='\033[0;33m' # Yellow
txtblu='\033[0;34m' # Blue


function showusage(){
	echo -e "Usage: \n$0 -n wait <command>"
	echo "Defaults:"
	exit 2
}

## Use getopt to read command agguments
args=`getopt n: $*`
if [ $? != 0 ]; then
	showusage
fi
set -- $args

# Process command arguments
for i
  do
	case "$i" in
		-n)
			WAIT="$2"; shift
			shift;;
		*)
			[ "$i" != "--" ] && [ "$i" != "$WAIT" ] && CMD="$CMD $i"
			shift;;
		--)
			shift; break;;
	esac
done

trap ctrl_c INT
function ctrl_c() {
        echo -e "\n${txtylw}executed $LOOP times${txtnone}" && exit 0
}

# Main Loop
while [ 0 ]; do
	clear
	columns="$(tput cols)"
	header="[ ${app_name} - refresh every ${WAIT} seconds ]"
	# Get the length of the padding on each side of the header text
	padlen=$(( $((${columns} / 2)) - $((${#header} /2)) ))
	# print the header text with padded characters
	printf "${txtgrn}"
	head -z -c $padlen < /dev/zero | tr '\0' '\52'
	printf "%s" "${header}"
	head -z -c $padlen < /dev/zero | tr '\0' '\52'
	printf "${txtnone}\n"
	# execute the command that is being watched
	$CMD
	ct=$WAIT
	# print the footer
	printf "${txtgrn}"
	head -z -c $columns < /dev/zero | tr '\0' '\52'
	printf "${txtnone}\n"

  # print a footer countdown to the next command execution
	while [ $ct -gt 0 ]; do
		sleep 1 &
		printf "\r${txtred}[ %02d:%02d ]${txtnone}${txtgrn} < ctrl-c to exit > ${txtnone}" $(((ct/60)%60)) $((ct%60))
		ct=$(( $ct - 1 ))
		wait
	done
	LOOP=$(( $LOOP + 1 ))
done
