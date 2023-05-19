# postgres-cron

Dockerfile for building postgresql:15.1 with pg_cron extension
Dockerfile installs [CitusData pg_cron extension installed](https://github.com/citusdata/pg_cron) for `postgres` database.
To change the database for `pg_cron` to be installed, give a value to `PG_CRON_DB` environment variable. It defaults to `pg_cron`.

# Building image

```sh
$ git clone https://github.com/KyudaHQ/postgres-cron.git
$ cd postgres-cron
$ docker build -t postgres-cron:15.3 .
```

# Publish image

```sh
$ `docker buildx build --platform=linux/amd64,linux/arm64 --push --tag kyuda/postgres-cron:15.3 .`
```

# Running image

```sh
$ docker run -d postgres-cron:15.3
```

# Testing pg_cron

```sh
$ docker exec --it [container-id] bash
$ su - postgres
$ psql
psql$ CREATE TABLE public.cron_test(a int);
psql$ INSERT INTO public.cron_test values (1), (2), (3) RETURNING *;
psql$ SELECT * FROM public.cron_test;
# Will return 1,2,3
psql$ select pg_sleep(60);
psql$ INSERT INTO cron.job (schedule, command, nodename, nodeport, database, username) VALUES ('* * * * *', $$DELETE FROM public.cron_test;$$, '', 5432, 'postgres', 'postgres') RETURNING jobid;
psql$ SELECT * FROM public.cron_test;
# Must return nothing since we deleted it with pg_cron
psql$ DELETE FROM cron.job;
psql$ DROP TABLE public.cron_test;
```