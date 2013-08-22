#!/bin/bash
# Mike Perron (2013)

database="./database"
deploydir="../../web"

init_db() {
	echo "Creating task database..."
	sqlite3 "$database" <<-EOF
		CREATE TABLE task(
			id integer primary key,
			title varchar not null,
			desc varchar not null,
			status integer default '1'
		);
EOF
}

cat << EOF
Automatic deploy script for Task Manager (task).
Mike Perron (2013)

You should have cloned this repository from Github as a subdirectory of your
Kraknet mods/ folder. That is to say, this file should be in:
	\$kraknet/mods/task/

EOF

if ! pushd src/ >/dev/null 2>&1; then
	cat <<-EOF
		src/ missing.
		Halting deploy.
EOF
	exit 1
fi

echo "Building binaries..."
if ! make; then
	cat <<-EOF
		Build failed!
		Halting deploy.
EOF
	exit 1
fi
popd >/dev/null 2>&1

if stat "$database" >/dev/null 2>&1; then
	echo -n "It looks like your database file already exists. Overwite? [y/N] "
	read yesno
	if [ "$yesno" == "y" ] || [ "$yesno" == "Y" ]; then
		echo "Deleting existing database..."
		rm "$database"
		init_db
	fi
else
	init_db
fi

if pwd | grep 'mods/task[/]*$' >/dev/null 2>&1; then
	echo "Directory looks OK."
else
	cat <<-EOF
		Whoa! Doesn't look like you're in a safe spot.
		Halting deploy.
EOF
	exit 1
fi

if stat "$deploydir" >/dev/null 2>&1; then
	echo -n "It looks like your web directory is at \"$deploydir\". Proceed with installation here? [Y/n] "
	read yesno

	if [ "$yesno" == "n" ] || [ "$yesno" == "N" ]; then
		exit 0
	fi
else
	cat <<-EOF
		Whoa! Your web directory is not in the default location.
		Halting deploy.
EOF
	exit 1
fi

if stat "$deploydir/task" >/dev/null 2>&1; then
	cat <<-EOF
		Whoa! A file $deploydir/task already exists.
		Halting Deploy.
EOF
	exit 1
fi

echo "Creating symlink in web/ ..."
cd $deploydir
ln -s -T ../mods/task/web/ task

cat << EOF

Done!
EOF
exit 0
