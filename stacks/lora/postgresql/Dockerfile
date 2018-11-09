FROM postgres:9.6-alpine

RUN mkdir -p /docker-entrypoint-initdb.d

COPY initdb/001-init-loraserver_ns.sh /docker-entrypoint-initdb.d/001-init-loraserver_ns.sh
COPY initdb/002-init-loraserver_as.sh /docker-entrypoint-initdb.d/002-init-loraserver_as.sh
COPY initdb/003-loraserver_as_trgm.sh /docker-entrypoint-initdb.d/003-loraserver_as_trgm.sh