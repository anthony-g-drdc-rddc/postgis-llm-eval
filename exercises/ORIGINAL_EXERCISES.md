# ORIGINAL EXERCISES

## 8. Simple SQL Exercises

Using the `nyc_census_blocks` table, answer the following questions (don’t peek at the answers!).

* **How many records are in the nyc_streets table?**

	```
	SELECT Count(*)
	FROM nyc_streets;
	```

	```
	19091
	```
* **How many streets in NYC start with ‘B’?**

	```
	SELECT Count(*)
		FROM nyc_streets
		WHERE name LIKE 'B%';
	```

	```
	1282
	```
* **What is the population of the City of New York?**

	```
	SELECT Sum(popn_total) AS population
		FROM nyc_census_blocks;
	```

	```
	8175032
	```
* **What is the population of the Bronx?**

	```
	SELECT Sum(popn_total) AS population
		FROM nyc_census_blocks
		WHERE boroname = 'The Bronx';
	```

	```
	1385108
	```
* **How many “neighborhoods” are in each borough?**

	```
	SELECT boroname, count(*)
		FROM nyc_neighborhoods
		GROUP BY boroname;
	```

	```
		 boroname    | count
	---------------+-------
	 Queens        |    30
	 Brooklyn      |    23
	 Staten Island |    24
	 The Bronx     |    24
	 Manhattan     |    28
	```
* **For each borough, what percentage of the population is white?**

	```
	SELECT
		boroname,
		100.0 * Sum(popn_white)/Sum(popn_total) AS white_pct
	FROM nyc_census_blocks
	GROUP BY boroname;
	```

	```
		 boroname    |    white_pct
	---------------+------------------
	 Brooklyn      | 42.8011737932687
	 Manhattan     | 57.4493039480463
	 The Bronx     | 27.9037446899448
	 Queens        |  39.722077394591
	 Staten Island | 72.8942034860154
	```

## 10. Geometry Exercises

* **What is the area of the ‘West Village’ neighborhood?**

	```
	SELECT ST_Area(geom)
		FROM nyc_neighborhoods
		WHERE name = 'West Village';
	```

	```
	1044614.5296486
	```
* **What is the geometry type of ‘Pelham St’? The length?**

	```
	SELECT
		 ST_GeometryType(geom),
		 ST_Length(geom)
		FROM nyc_streets
		WHERE name = 'Pelham St';
	```

	```
	ST_MultiLineString
	50.323
	```
* **What is the GeoJSON representation of the ‘Broad St’ subway station?**

	```
	SELECT
	 ST_AsGeoJSON(geom)
	FROM nyc_subway_stations
	WHERE name = 'Broad St';
	```

	```
	{"type":"Point",
	 "crs":{"type":"name","properties":{"name":"EPSG:26918"}},
	 "coordinates":[583571.905921312,4506714.341192182]}
	```
* **What is the total length of streets (in kilometers) in New York City?**

	```
	SELECT Sum(ST_Length(geom)) / 1000
		FROM nyc_streets;
	```

	```
	10418.9047172
	```
* **What is the area of Manhattan in acres?**

	```
	SELECT Sum(ST_Area(geom)) / 4047
		FROM nyc_neighborhoods
		WHERE boroname = 'Manhattan';
	```

	```
	13965.3201224118
	```

	or…

	```
	SELECT Sum(ST_Area(geom)) / 4047
		FROM nyc_census_blocks
		WHERE boroname = 'Manhattan';
	```

	```
	14601.3987215548
	```
* **What is the most westerly subway station?**

	```
	SELECT ST_X(geom), name
		FROM nyc_subway_stations
		ORDER BY ST_X(geom)
		LIMIT 1;
	```

	```
	Tottenville
	```
* **How long is ‘Columbus Cir’ (aka Columbus Circle)?**

	```
	SELECT ST_Length(geom)
		FROM nyc_streets
		WHERE name = 'Columbus Cir';
	```

	```
	308.34199
	```
* **What is the length of streets in New York City, summarized by type?**

	```
	SELECT type, Sum(ST_Length(geom)) AS length
	FROM nyc_streets
	GROUP BY type
	ORDER BY length DESC;
	```

	```
												 type                       |      length
	--------------------------------------------------+------------------
	 residential                                      | 8629870.33786606
	 motorway                                         | 403622.478126363
	 tertiary                                         | 360394.879051303
	 motorway_link                                    | 294261.419479668
	 secondary                                        | 276264.303897926
	 unclassified                                     | 166936.371604458
	 primary                                          | 135034.233017947
	 footway                                          | 71798.4878378096
	 service                                          |  28337.635038596
	 trunk                                            | 20353.5819826076
	 cycleway                                         | 8863.75144825929
	 pedestrian                                       | 4867.05032825026
	 construction                                     | 4803.08162103562
	 residential; motorway_link                       | 3661.57506293745
	 trunk_link                                       | 3202.18981240201
	 primary_link                                     | 2492.57457083536
	 living_street                                    | 1894.63905457332
	 primary; residential; motorway_link; residential | 1367.76576941335
	 undefined                                        |  380.53861910346
	 steps                                            | 282.745221342127
	 motorway_link; residential                       |  215.07778911517
	```

## 12. Spatial Relationships Exercises

* **What is the geometry value for the street named ‘Atlantic Commons’?**

	```
	SELECT ST_AsText(geom)
		FROM nyc_streets
		WHERE name = 'Atlantic Commons';
	```

	```
	MULTILINESTRING((586781.701577724 4504202.15314339,586863.51964484 4504215.9881701))
	```
* **What neighborhood and borough is Atlantic Commons in?**

	```
	SELECT name, boroname
	FROM nyc_neighborhoods
	WHERE ST_Intersects(
		geom,
		ST_GeomFromText('LINESTRING(586782 4504202,586864 4504216)', 26918)
	);
	```

	```
			name    | boroname
	------------+----------
	 Fort Green | Brooklyn
	```
* **What streets does Atlantic Commons join with?**

	```
	SELECT name
	FROM nyc_streets
	WHERE ST_DWithin(
		geom,
		ST_GeomFromText('LINESTRING(586782 4504202,586864 4504216)', 26918),
		0.1
	);
	```

	```
			 name
	------------------
	 Cumberland St
	 Atlantic Commons
	```
* **Approximately how many people live on (within 50 meters of) Atlantic Commons?**

	```
	SELECT Sum(popn_total)
		FROM nyc_census_blocks
		WHERE ST_DWithin(
		 geom,
		 ST_GeomFromText('LINESTRING(586782 4504202,586864 4504216)', 26918),
		 50
		);
	```

	```
	1438
	```

## 14. Spatial Joins Exercises

* **What subway station is in ‘Little Italy’? What subway route is it on?**

	```
	SELECT s.name, s.routes
	FROM nyc_subway_stations AS s
	JOIN nyc_neighborhoods AS n
	ON ST_Contains(n.geom, s.geom)
	WHERE n.name = 'Little Italy';
	```

	```
		 name    | routes
	-----------+--------
	 Spring St | 6
	```
* **What are all the neighborhoods served by the 6-train?**

	```
	SELECT DISTINCT n.name, n.boroname
	FROM nyc_subway_stations AS s
	JOIN nyc_neighborhoods AS n
	ON ST_Contains(n.geom, s.geom)
	WHERE strpos(s.routes,'6') > 0;
	```

	```
					name        | boroname
	--------------------+-----------
	 Midtown            | Manhattan
	 Hunts Point        | The Bronx
	 Gramercy           | Manhattan
	 Little Italy       | Manhattan
	 Financial District | Manhattan
	 South Bronx        | The Bronx
	 Yorkville          | Manhattan
	 Murray Hill        | Manhattan
	 Mott Haven         | The Bronx
	 Upper East Side    | Manhattan
	 Chinatown          | Manhattan
	 East Harlem        | Manhattan
	 Greenwich Village  | Manhattan
	 Parkchester        | The Bronx
	 Soundview          | The Bronx
	```
* **After 9/11, the ‘Battery Park’ neighborhood was off limits for several days. How many people had to be evacuated?**

	```
	SELECT Sum(popn_total)
	FROM nyc_neighborhoods AS n
	JOIN nyc_census_blocks AS c
	ON ST_Intersects(n.geom, c.geom)
	WHERE n.name = 'Battery Park';
	```

	```
	17153
	```
* **What neighborhood has the highest population density (persons/km2)?**

	```
	SELECT
		n.name,
		Sum(c.popn_total) / (ST_Area(n.geom) / 1000000.0) AS popn_per_sqkm
	FROM nyc_census_blocks AS c
	JOIN nyc_neighborhoods AS n
	ON ST_Intersects(c.geom, n.geom)
	GROUP BY n.name, n.geom
	ORDER BY popn_per_sqkm DESC LIMIT 2;
	```

	```
				name       |  popn_per_sqkm
	-------------------+------------------
	 North Sutton Area | 68435.13283772678
	 East Village      | 50404.48341332535
	```

## 17. Projection Exercises

* **What is the length of all streets in New York, as measured in UTM 18?**

	```
	SELECT Sum(ST_Length(geom))
		FROM nyc_streets;
	```

	```
	10418904.7172
	```
* **What is the WKT definition of SRID 2831?**

	```
	SELECT srtext FROM spatial_ref_sys
	WHERE SRID = 2831;
	```

	```
	PROJCS["NAD83(HARN) / New York Long Island",
		GEOGCS["NAD83(HARN)",
			DATUM["NAD83 (High Accuracy Regional Network)",
				SPHEROID["GRS 1980", 6378137.0, 298.257222101,
					AUTHORITY["EPSG","7019"]],
				TOWGS84[-0.991, 1.9072, 0.5129, 0.0257899075194932, -0.009650098960270402, -0.011659943232342112, 0.0],
				AUTHORITY["EPSG","6152"]],
			PRIMEM["Greenwich", 0.0,
				AUTHORITY["EPSG","8901"]],
			UNIT["degree", 0.017453292519943295],
			AXIS["Geodetic longitude", EAST],
			AXIS["Geodetic latitude", NORTH],
			AUTHORITY["EPSG","4152"]],
		PROJECTION["Lambert Conic Conformal (2SP)",
			AUTHORITY["EPSG","9802"]],
		PARAMETER["central_meridian", -74.0],
		PARAMETER["latitude_of_origin", 40.166666666666664],
		PARAMETER["standard_parallel_1", 41.03333333333333],
		PARAMETER["false_easting", 300000.0],
		PARAMETER["false_northing", 0.0],
		PARAMETER["scale_factor", 1.0],
		PARAMETER["standard_parallel_2", 40.666666666666664],
		UNIT["m", 1.0],
		AXIS["Easting", EAST],
		AXIS["Northing", NORTH],
		AUTHORITY["EPSG","2831"]]
	```
* **What is the length of all streets in New York, as measured in SRID 2831?**

	```
	SELECT Sum(ST_Length(ST_Transform(geom,2831)))
		FROM nyc_streets;
	```

	```
	10421993.706374
	```
* **How many streets cross the 74th meridian?**

	```
	SELECT Count(*)
	FROM nyc_streets
	WHERE ST_Intersects(
		ST_Transform(geom, 4326),
		'SRID=4326;LINESTRING(-74 20, -74 60)'
		);
	```

	```
	223
	```

## 19. Geography Exercises

* **How far is New York from Seattle? What are the units of the answer?**

	```
	SELECT ST_Distance(
		'POINT(-74.0064 40.7142)'::geography,
		'POINT(-122.3331 47.6097)'::geography
		);
	```

	```
	3875538.57141352
	```
* **What is the total length of all streets in New York, calculated on the spheroid?**

	```
	SELECT Sum(
		ST_Length(Geography(
			ST_Transform(geom,4326)
		)))
	FROM nyc_streets;
	```

	```
	10421999.666
	```
* **Does ‘POINT(1 2.0001)’ intersect with ‘POLYGON((0 0, 0 2, 2 2, 2 0, 0 0))’ in geography? In geometry? Why the difference?**

	```
	SELECT ST_Intersects(
		'POINT(1 2.0001)'::geography,
		'POLYGON((0 0,0 2,2 2,2 0,0 0))'::geography
	);

	SELECT ST_Intersects(
		'POINT(1 2.0001)'::geometry,
		'POLYGON((0 0,0 2,2 2,2 0,0 0))'::geometry
	);
	```

	```
	true and false
	```

## 21. Geometry Constructing Exercises

* **How many census blocks don’t contain their own centroid?**

	```
	SELECT Count(*)
		FROM nyc_census_blocks
		WHERE NOT
			ST_Contains(
				geom,
				ST_Centroid(geom)
			);
	```

	```
	481
	```
* **Union all the census blocks into a single output. What kind of geometry is it? How many parts does it have?**

	```
	CREATE TABLE nyc_census_blocks_merge AS
		SELECT ST_Union(geom) AS geom
		FROM nyc_census_blocks;

	SELECT ST_GeometryType(geom)
		FROM nyc_census_blocks_merge;
	```

	```
	ST_MultiPolygon
	```

	```
	SELECT ST_NumGeometries(geom)
		FROM nyc_census_blocks_merge;
	```

	```
	63
	```
* **What is the area of a one unit buffer around the origin? How different is it from what you would expect? Why?**

	```
	SELECT ST_Area(ST_Buffer('POINT(0 0)', 1));
	```

	```
	3.121445152258052
	```
* **The Brooklyn neighborhoods of ‘Park Slope’ and ‘Carroll Gardens’ are going to war! Construct a polygon delineating a 100 meter wide DMZ on the border between the neighborhoods. What is the area of the DMZ?**

	```
	CREATE TABLE brooklyn_dmz AS
		SELECT
			ST_Intersection(
				ST_Buffer(ps.geom, 50),
				ST_Buffer(cg.geom, 50))
			AS geom
		FROM
			nyc_neighborhoods ps,
			nyc_neighborhoods cg
		WHERE ps.name = 'Park Slope'
		AND cg.name = 'Carroll Gardens';

	SELECT ST_Area(geom) FROM brooklyn_dmz;
	```

	```
	180990.964207547
	```
