#!/bin/bash

database="database"

echo "Creating task database..."
sqlite3 "$database" << EOF
CREATE TABLE task(
	id integer primary key,
	title varchar not null,
	desc varchar not null,
	status integer default '1'
);
EOF
