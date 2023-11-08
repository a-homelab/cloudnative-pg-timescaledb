# syntax=docker/dockerfile:latest

ARG POSTGRES_VERSION

# https://github.com/cloudnative-pg/cloudnative-pg/pkgs/container/cloudnative-pg
FROM ghcr.io/cloudnative-pg/postgresql:${POSTGRES_VERSION}

ARG TIMESCALEDB_VERSION
ARG POSTGRES_VERSION

USER root

RUN <<EOF
    export POSTGRES_MAJOR_VERSION="$(echo "${POSTGRES_VERSION}" | cut -d '.' -f 1)"
    apt-get update && apt-get install -y wget
    mkdir -m 755 /etc/apt/keyrings
    echo "deb [signed-by=/etc/apt/keyrings/timescaledb-archive-keyring.gpg] https://packagecloud.io/timescale/timescaledb/debian/ bullseye main" | tee /etc/apt/sources.list.d/timescaledb.list
    wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | gpg --dearmor -o /etc/apt/keyrings/timescaledb-archive-keyring.gpg
    apt-get update && apt-get install -y "timescaledb-2-${TIMESCALEDB_VERSION}-postgresql-${POSTGRES_MAJOR_VERSION}=${TIMESCALEDB_VERSION}~debian11"
    apt-get purge -y --autoremove wget
    rm -rf /var/lib/apt/lists/*
EOF

USER postgres
