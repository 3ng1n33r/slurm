#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
	CREATE USER yelbuser WITH PASSWORD 'yelbpassword';
    CREATE DATABASE yelbdatabase;
	GRANT ALL PRIVILEGES ON DATABASE yelbdatabase TO yelbuser;
	ALTER DATABASE yelbdatabase OWNER TO yelbuser;
    \connect yelbdatabase;
	CREATE TABLE restaurants (
    	name        char(30),
    	count       integer,
    	PRIMARY KEY (name)
	);
	INSERT INTO restaurants (name, count) VALUES ('outback', 0);
	INSERT INTO restaurants (name, count) VALUES ('bucadibeppo', 0);
	INSERT INTO restaurants (name, count) VALUES ('chipotle', 0);
	INSERT INTO restaurants (name, count) VALUES ('ihop', 0);
	ALTER TABLE restaurants OWNER TO yelbuser;
EOSQL

