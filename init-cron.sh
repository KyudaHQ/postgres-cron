#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE DATABASE pg_cron;
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "pg_cron" <<-EOSQL
	CREATE EXTENSION pg_cron;
EOSQL