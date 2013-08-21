#!/bin/bash
# Mike Perron (2013)

IFS=$'\n'
possiblestates=($(mod_find task:states))

IFS="&;"
for ARG in $QUERY_STRING; do
	case $ARG in
		*=*)
			declare "${ARG%%=*}=${ARG#*=}"
			;;
	esac
done


cat << EOF
	<form>
		<select name=ll>
EOF

for (( level=0; level<${#possiblestates[@]}; level++ )); do
	echo -n "<option value=\"$level\""
	if [ -n "$ll" ] && [ "$level" -eq "$ll" ]; then
		echo -n " selected"
	fi
	echo ">${possiblestates[$level]}</option>"
done

cat << EOF
		</select>
		<input type=submit value="Set Minimum Visibility">
	</form>
EOF
