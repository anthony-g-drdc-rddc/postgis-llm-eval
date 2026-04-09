# postgis-llm-eval

This repository builds a local PostGIS database container and loads the sample Canada datasets from `data/` during first-time initialization.

## Prerequisites

- Docker with the Compose plugin (`docker compose`)

## Build the image

```bash
docker compose build
```

## Start the database

```bash
docker compose up -d
```

The database service is exposed on `localhost:5433` and uses these credentials:

- Database: `gis`
- User: `postgres`
- Password: `postgres`

On the first startup, the container runs the initialization scripts in `docker/initdb/` and loads:

- `canada_census_divisions`
- `canada_airports`
- `canada_roads`
- `canada_religions_census_data`

## Check that the service is ready

```bash
docker compose ps
```

You can also inspect logs if initialization is still running:

```bash
docker compose logs -f postgis
```

## Connect to the database

Using `psql` from your host:

```bash
psql "host=localhost port=5433 dbname=gis user=postgres password=postgres"
```

Or open a shell inside the running container:

```bash
docker exec -it postgis-llm-eval-db psql -U postgres -d gis
```

## Print table information

List the tables loaded into the `public` schema:

```bash
docker exec -it postgis-llm-eval-db psql -U postgres -d gis -c "\dt public.*"
```

Show the columns, indexes, and table details for one table:

```bash
docker exec -it postgis-llm-eval-db psql -U postgres -d gis -c "\d+ public.canada_census_divisions"
```

Print row counts for all loaded tables:

```bash
docker exec -it postgis-llm-eval-db psql -U postgres -d gis -c "SELECT 'canada_census_divisions' AS table_name, COUNT(*) AS row_count FROM public.canada_census_divisions UNION ALL SELECT 'canada_airports', COUNT(*) FROM public.canada_airports UNION ALL SELECT 'canada_roads', COUNT(*) FROM public.canada_roads UNION ALL SELECT 'canada_religions_census_data', COUNT(*) FROM public.canada_religions_census_data;"
```

Print geometry column metadata for the spatial tables:

```bash
docker exec -it postgis-llm-eval-db psql -U postgres -d gis -c "SELECT f_table_name, f_geometry_column, srid, type FROM public.geometry_columns ORDER BY f_table_name;"
```

## Stop the database

```bash
docker compose down
```

## Rebuild from a clean database state

The PostgreSQL data directory is stored in the named volume `postgis_data`. If you want to re-run the initialization scripts from scratch:

```bash
docker compose down -v
docker compose build
docker compose up -d
```

## Common workflow

```bash
docker compose build
docker compose up -d
docker compose ps
docker exec -it postgis-llm-eval-db psql -U postgres -d gis
```