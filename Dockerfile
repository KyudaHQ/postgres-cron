FROM postgres:15.3
LABEL MAINTAINER Kyuda <hello@kyuda.io>

# Prepare ENVs
ENV PG_CRON_VERSION           "1.5.2"

# Prepare the build requirements for the rdkit compilation:
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-server-dev-all postgresql-contrib \
    libcurl4-openssl-dev \
    wget jq cmake build-essential ca-certificates && \
# Install pg_cron:
    mkdir /build && \
    cd /build && \
    wget https://github.com/citusdata/pg_cron/archive/v$PG_CRON_VERSION.tar.gz && \
    tar xzvf v$PG_CRON_VERSION.tar.gz && \
    cd pg_cron-$PG_CRON_VERSION && \
    make && \
    make install && \
# Clean up:
    cd / && \
    rm -rf /build && \
    apt-get remove -y wget jq cmake build-essential ca-certificates && \
    apt-get autoremove --purge -y && \
    apt-get clean && \
    apt-get purge && \
    rm -rf /var/lib/apt/lists/*
# Done.

# Get the default config
RUN cat /usr/share/postgresql/postgresql.conf.sample > postgres-cron.conf

# Configure pg_cron
RUN echo "shared_preload_libraries = 'pg_cron'" >> /usr/share/postgresql/postgresql.conf.sample
# RUN echo "cron.database_name = 'pg_cron'" >> /usr/share/postgresql/postgresql.conf.sample
RUN echo "cron.database_name = 'postgres'" >> /usr/share/postgresql/postgresql.conf.sample
RUN echo "listen_addresses = '*'" >> /usr/share/postgresql/postgresql.conf.sample

# COPY init-cron.sh /docker-entrypoint-initdb.d/

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]