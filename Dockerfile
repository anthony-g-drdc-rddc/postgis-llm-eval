FROM postgis/postgis:16-3.4 AS postgis-tools

RUN apt-get update \
	&& apt-get install -y --no-install-recommends postgis \
	&& rm -rf /var/lib/apt/lists/*

FROM postgis/postgis:16-3.4

COPY --from=postgis-tools /usr/bin/shp2pgsql /usr/bin/shp2pgsql

COPY data /opt/data
COPY docker/initdb /docker-entrypoint-initdb.d

RUN chmod +x /docker-entrypoint-initdb.d/10-load-data.sh

ENV POSTGRES_DB=gis \
	POSTGRES_USER=postgres \
	POSTGRES_PASSWORD=postgres
