#!/bin/bash
# Mike Perron (2013)

database="$mod_root/task/database"

read -e POST
if [ -n "$POST" ]; then
	declare "QUERY_STRING=$POST"
#	echo "Using POST data: <span>$POST</span>"
fi

IFS="&;"
for ARG in $QUERY_STRING; do
	case $ARG in
		*=*)
			declare "${ARG%%=*}=${ARG#*=}"
			;;
	esac
done

case $mode in
	set)
		if [ -n "$id" ]; then
			if [ -n "$state" ]; then
				op="update task set status='$state' where id='$id';"
				sqlite3 "$database" <<< "$op"
				echo "Status updated.<br>"
			fi
			if [ -n "$desc" ]; then
				op="update task set desc='$desc' where id='$id';"
				sqlite3 "$database" <<< "$op"
				echo "Description updated.<br>"
			fi
			if [ -n "$title" ]; then
				op="update task set title='$title' where id='$id';"
				sqlite3 "$database" <<< "$op"
				echo "Title updated.<br>"
			fi
			echo "<a href=\"?mode=view&id=$id\">View task</a>."
		fi
		;;
	add)
		if [ -z "$title" ] || [ -z "$desc" ]; then
			echo "Missing information. Can't create that task."
			exit 1
		fi
		op="insert into task(title,desc) values('$title','$desc');"
		sqlite3 "$database" <<< "$op"	
		;;
	del)
		if [ -n "$id" ]; then
			op="delete from task where id='$id';"
			sqlite3 "$database" <<< "$op"
		else
			echo "ID value not set, nothing deleted."
		fi
		;;
	view)
		op="select status, title, desc from task where id='$id';"
		rt=$(sqlite3 "$database" <<< "$op")

		IFS=$'|'
		rt=($rt)

		state=${rt[0]}
		title=$(mod_find task:decode <<< "${rt[1]}" | sed 's/</\&lt;/g')
		desc=$(mod_find task:decode <<< "${rt[2]}" | sed 's/</\&lt;/g')

		case $state in
			2)	statef="Escalated" ;;
			1)	statef="In Progress" ;;
			0)	statef="Complete" ;;
			*)	statef="Other ($state)" ;;
		esac
		echo "<h2>$title</h2>"
		echo "<h3>Status: $statef</h3><p id=\"viewdesc\">$desc</p><a href=\"?mode=edit&id=$id\">Edit This Task</a>"
		;;
	edit)
		op="select title, desc from task where id='$id';"
		rt=$(sqlite3 "$database" <<< "$op")

		IFS=$'|'
		rt=($rt)

		title=$(mod_find task:decode <<< "${rt[0]}" | sed 's/</\&lt;/g' | sed 's/"/\&quot;/g')
		desc=$(mod_find task:decode <<< "${rt[1]}" | sed 's/</\&lt;/g' | sed 's/"/\&quot;/g')

		cat << EOF
<form method=POST>
	<input type=hidden name=mode value=set>
	<input type=hidden name=id value=$id>
	<label for="edittitle">Title</label>
	<input name=title id="edittitle" value="$title"><br>
	<textarea name=desc id="edittextarea">$desc</textarea><br>
	<input type=submit value="Update">
</form>
EOF
		;;
	status)
		op="select desc from task where status<>'0';"
		IFS=$'\n'
		echo "Open Tasks"
		echo "<ul>"
		for TASK in $(sqlite3 "$database" <<< "$op"); do
			echo "<li>$(mod_find task:decode <<< "$TASK" | sed 's/</\&lt;/g')</li>"
		done
		echo "</ul>"
		;;
esac
