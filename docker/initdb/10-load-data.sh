#!/usr/bin/env bash
set -euo pipefail

psql_cmd=(psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB")

load_shapefile() {
  local srid="$1"
  local source_path="$2"
  local target_table="$3"
    local encoding="${4:-LATIN1}"

  echo "Loading ${target_table} from ${source_path}"
    shp2pgsql -D -I -W "$encoding" -s "$srid" "$source_path" "public.${target_table}" | "${psql_cmd[@]}"
}

load_shapefile 3347 /opt/data/canada_census_divisions/lcd_000a21a_e.shp canada_census_divisions LATIN1
load_shapefile 4269 /opt/data/canada_airports/Airports_Aeroports_en_shape.shp canada_airports LATIN1
load_shapefile 3347 /opt/data/canada_roads/lrnf000r21a_e.shp canada_roads LATIN1

"${psql_cmd[@]}" <<'SQL'
CREATE TABLE public.canada_religions_census_data_stage (
    source_row_id integer PRIMARY KEY,
    dguid varchar(21) NOT NULL,
    buddhist_total double precision,
    buddhist_men double precision,
    buddhist_women double precision,
    christian_total double precision,
    christian_men double precision,
    christian_women double precision,
    hindu_total double precision,
    hindu_men double precision,
    hindu_women double precision,
    jewish_total double precision,
    jewish_men double precision,
    jewish_women double precision,
    muslim_total double precision,
    muslim_men double precision,
    muslim_women double precision,
    no_religion_total double precision,
    no_religion_men double precision,
    no_religion_women double precision,
    other_religions_total double precision,
    other_religions_men double precision,
    other_religions_women double precision,
    sikh_total double precision,
    sikh_men double precision,
    sikh_women double precision,
    indigenous_spirituality_total double precision,
    indigenous_spirituality_men double precision,
    indigenous_spirituality_women double precision
);

CREATE TABLE public.canada_religions_census_data (
    source_row_id integer PRIMARY KEY,
    dguid varchar(21) NOT NULL,
    buddhist_total double precision,
    buddhist_men double precision,
    buddhist_women double precision,
    christian_total double precision,
    christian_men double precision,
    christian_women double precision,
    hindu_total double precision,
    hindu_men double precision,
    hindu_women double precision,
    jewish_total double precision,
    jewish_men double precision,
    jewish_women double precision,
    muslim_total double precision,
    muslim_men double precision,
    muslim_women double precision,
    no_religion_total double precision,
    no_religion_men double precision,
    no_religion_women double precision,
    other_religions_total double precision,
    other_religions_men double precision,
    other_religions_women double precision,
    sikh_total double precision,
    sikh_men double precision,
    sikh_women double precision,
    indigenous_spirituality_total double precision,
    indigenous_spirituality_men double precision,
    indigenous_spirituality_women double precision
);
SQL

"${psql_cmd[@]}" <<'SQL'
\copy public.canada_religions_census_data_stage FROM '/opt/data/canada_religions_census_data.csv' WITH (FORMAT csv, HEADER true)
SQL

"${psql_cmd[@]}" <<'SQL'
INSERT INTO public.canada_religions_census_data (
    source_row_id,
    dguid,
    buddhist_total,
    buddhist_men,
    buddhist_women,
    christian_total,
    christian_men,
    christian_women,
    hindu_total,
    hindu_men,
    hindu_women,
    jewish_total,
    jewish_men,
    jewish_women,
    muslim_total,
    muslim_men,
    muslim_women,
    no_religion_total,
    no_religion_men,
    no_religion_women,
    other_religions_total,
    other_religions_men,
    other_religions_women,
    sikh_total,
    sikh_men,
    sikh_women,
    indigenous_spirituality_total,
    indigenous_spirituality_men,
    indigenous_spirituality_women
)
SELECT
    stage.source_row_id,
    stage.dguid,
    stage.buddhist_total,
    stage.buddhist_men,
    stage.buddhist_women,
    stage.christian_total,
    stage.christian_men,
    stage.christian_women,
    stage.hindu_total,
    stage.hindu_men,
    stage.hindu_women,
    stage.jewish_total,
    stage.jewish_men,
    stage.jewish_women,
    stage.muslim_total,
    stage.muslim_men,
    stage.muslim_women,
    stage.no_religion_total,
    stage.no_religion_men,
    stage.no_religion_women,
    stage.other_religions_total,
    stage.other_religions_men,
    stage.other_religions_women,
    stage.sikh_total,
    stage.sikh_men,
    stage.sikh_women,
    stage.indigenous_spirituality_total,
    stage.indigenous_spirituality_men,
    stage.indigenous_spirituality_women
FROM public.canada_religions_census_data_stage AS stage
INNER JOIN public.canada_census_divisions AS divisions
    ON divisions.dguid = stage.dguid;

DROP TABLE public.canada_religions_census_data_stage;

CREATE INDEX canada_census_divisions_dguid_idx
    ON public.canada_census_divisions (dguid);

CREATE INDEX canada_religions_census_data_dguid_idx
    ON public.canada_religions_census_data (dguid);

ANALYZE public.canada_census_divisions;
ANALYZE public.canada_airports;
ANALYZE public.canada_roads;
ANALYZE public.canada_religions_census_data;
SQL
