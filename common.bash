# Common startup and utilities for Task scripts.
# Mike Perron (2013)
OIFS=$IFS


database="$mod_root/task/database"
possiblestates=("Complete" "In Progress" "Escalated")

IFS="&;"
for ARG in $QUERY_STRING; do
	case $ARG in
		*=*)
			declare "${ARG%%=*}=${ARG#*=}"
			;;
	esac
done


IFS=$OIFS
