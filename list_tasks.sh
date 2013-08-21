#!/bin/bash
# Mike Perron (2013)

database="$mod_root/task/database"

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
<table>
<tr>
	<th>Task</th>
	<th>Description</th>
	<th>State</th>
	<th>Actions</th>
</tr>
EOF

IFS=$'\n'
for TASKA in $(sqlite3 $database <<< "select id, status, title, desc from task order by status desc;"); do
	IFS=$'|'
	TASKA=($TASKA)
	id=${TASKA[0]}
	state=${TASKA[1]}
	if [ -n "$ll" ] && [ "$state" -lt "$ll" ]; then
		continue;
	fi

	title=$(mod_find task:decode <<< "${TASKA[2]}" | sed -e 's/</\&lt;/g' | sed -e 's/"/\&quot;/g')
	desc=$(mod_find task:decode <<< "${TASKA[3]}" | sed -e 's/</\&lt;/g' | sed -e 's/"/\&quot;/g')

	descs="$desc"
	if [ "${#desc}" -ge 48 ]; then
		descs="${desc:0:45}..."
	fi
	titles="$title"
	if [ "${#title}" -ge 48 ]; then
		titles="${title:0:45}..."
	fi

	if [ "$state" -lt "${#possiblestates[@]}" ]; then
		statef="<span class=\"priority_$state\">${possiblestates[$state]}</span>"
	else
		statef="<span class=\"priority_$state\">Other ($state)</span>"
	fi

cat << EOF
<tr class="taskrow">
	<td class=clickabletd title="$title" onclick="window.location='?ll=$ll&mode=view&id=$id'">$titles</td>
	<td class=clickabletd title="$desc" onclick="window.location='?ll=$ll&mode=view&id=$id'">$descs</td>
	<td>$statef</td>
	<td><form>
		<input type=hidden name=mode value=set>
		<input type=hidden name=id value=$id>
		<input type=hidden name=ll value=$ll>
		<select name=state>
			<option value=0>Complete</option>
			<option value=1>In Progress</option>
			<option value=2>Escalated</option>
		</select>
		<input type=submit value="Set">
	</form></td>
	<td><a href="?ll=$ll&mode=del&id=$id">Delete</a></td>
</tr>
EOF
done

echo "</table>"
