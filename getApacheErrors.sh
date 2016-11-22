#!/bin/sh
##################################
# CREATED BY: Luis L.
# DESC: This script will report the errors found on 
# 		the apache access log. It will associate the IPs
#		and count the errors found. 
#
#		At the moment it only support 404 and 403 errors
#		but we can add more if we have to or make it a bit
# 		more dynamic.
#############
# VARS
declare -a IP_List;
declare -a ERROR_LIST;
ACCESS_LOG=$1
#############
# FUNCTIONS
function checkParams(){
	if [ ! $# -eq 1 ]; then
		usage;
		exit 1
	fi
}

function usage(){
	echo Usage is as follows:
	echo `basename $0` "<ACCESS_LOG>"
}

function populateIPs(){
	for IP in `cat $ACCESS_LOG | awk '$9 ~ /^4/ {print $1}' | sort | uniq`; do
	    ((index++))
	done
}

function populateErrors(){
	for ERROR in `cat $ACCESS_LOG | awk '$9 ~ /^4/ {print $9}' | sort | uniq`; do
    	ERROR_List[index]=$ERROR
    	((index++))
	done
}
##############
# RUNTIME
checkParams
populateIPs
populateErrors

iCount403=`cat $ACCESS_LOG | awk '$9 ~ /^403/ {print $1" "$9}' | sort | wc -l`
iCount404=`cat $ACCESS_LOG | awk '$9 ~ /^404/ {print $1" "$9}' | sort | wc -l`
for foundIP in ${IP_List[@]}; do
	ERROR1=`cat $ACCESS_LOG | grep $foundIP | awk '$9 ~ /^404/ {print $9}' | sort | uniq`
	ERROR2=`cat $ACCESS_LOG | grep $foundIP | awk '$9 ~ /^403/ {print $9}' | sort | uniq`
	if [[ -n $ERROR1 && $ERROR1 -eq 404 ]]; then
		echo COUNT: $iCount404 - IP: $foundIP - ERROR: 404;
	fi
	if [[ -n $ERROR2 && $ERROR2 -eq 403 ]]; then
		echo COUNT: $iCount403 - IP: $foundIP - ERROR: 403;
	fi
done

echo
echo "We have ${#ERROR_List[*]} type of errors:"
echo "$iCount404 404(s)"
echo "$iCount403 403(s)"

exit 0
