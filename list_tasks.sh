#!/bin/bash
# Mike Perron (2013)
. common.bash

currentid=$id

cat << EOF
<div id=tasklistdiv>
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

	if [ "$id" -eq "$currentid" ]; then
		currentids=" id=\"currenttaskinlist\""
	else
		currentids=""
	fi

cat << EOF
<tr class="taskrow"$currentids>
	<td class=clickabletd title="$title" onclick="window.location='?ll=$ll&mode=view&id=$id'">$titles</td>
	<td class=clickabletd title="$desc" onclick="window.location='?ll=$ll&mode=view&id=$id'">$descs</td>
	<td>$statef</td>
	<td><form>
		<input type=hidden name=mode value=set>
		<input type=hidden name=id value=$id>
		<input type=hidden name=ll value=$ll>
		<select name=state>
EOF
	for (( i=0; i<${#possiblestates[@]}; i++ )); do
		echo "<option value=$i>${possiblestates[$i]}</option>"
	done
cat << EOF
		</select>
		<input type=submit value="Set">
	</form></td>
	<td><a href="?ll=$ll&mode=del&id=$id">Delete</a></td>
</tr>
EOF
done

cat << EOF
</table>
</div>
EOF
