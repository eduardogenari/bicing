-- hacemos particiones de tabla stations_status_t1 para poder trabajar con ella
-- si no hacemos partición, los tiempos de ejecución son extremadamente largos
SELECT *
INTO stations_status_t1_1to100
FROM stations_status_t1
WHERE station_id BETWEEN 1 AND 100

SELECT *
INTO stations_status_t1_101to200
FROM stations_status_t1
WHERE station_id BETWEEN 101 AND 200

SELECT *
INTO stations_status_t1_201to300
FROM stations_status_t1
WHERE station_id BETWEEN 201 AND 300

SELECT *
INTO stations_status_t1_301to400
FROM stations_status_t1
WHERE station_id BETWEEN 301 AND 400

SELECT *
INTO stations_status_t1_401to500
FROM stations_status_t1
WHERE station_id BETWEEN 401 AND 500

SELECT *
INTO stations_status_t1_501to600
FROM stations_status_t1
WHERE station_id BETWEEN 501 AND 600

-- guardamos la relación entre un instante de una estación y justo el anterior de la misma estación.
-- esto nos ayudará a calcular diferencias
CREATE TABLE IF NOT EXISTS public.stations_status_previous
(
    bicing_station_status_id integer NOT NULL,
    previous_bicing_station_status_id integer
)

-- eliminamos duplicados (hay reportes de estaciones en el mismo momento. Nos quedaremos el último según last_updated)
INSERT INTO public.stations_status_previous_part (bicing_station_status_id, previous_bicing_station_status_id)
SELECT id, LAG(id) OVER (PARTITION BY station_id ORDER BY last_reported)
FROM stations_status_t1_1to100 st;

INSERT INTO public.stations_status_previous_part (bicing_station_status_id, previous_bicing_station_status_id)
SELECT id, LAG(id) OVER (PARTITION BY station_id ORDER BY last_reported)
FROM stations_status_t1_101to200 st;

INSERT INTO public.stations_status_previous_part (bicing_station_status_id, previous_bicing_station_status_id)
SELECT id, LAG(id) OVER (PARTITION BY station_id ORDER BY last_reported)
FROM stations_status_t1_201to300 st;

INSERT INTO public.stations_status_previous_part (bicing_station_status_id, previous_bicing_station_status_id)
SELECT id, LAG(id) OVER (PARTITION BY station_id ORDER BY last_reported)
FROM stations_status_t1_301to400 st;

INSERT INTO public.stations_status_previous_part (bicing_station_status_id, previous_bicing_station_status_id)
SELECT id, LAG(id) OVER (PARTITION BY station_id ORDER BY last_reported)
FROM stations_status_t1_401to500 st;

INSERT INTO public.stations_status_previous_part (bicing_station_status_id, previous_bicing_station_status_id)	
SELECT id, LAG(id) OVER (PARTITION BY station_id ORDER BY last_reported)
FROM stations_status_t1_501to600 st;

CREATE TABLE IF NOT EXISTS public.stations_timestamps
(
	station_status_id integer not null, 
	station_id smallint not null,
    last_reported timestamp,
    initial_num_bikes_available smallint,
    initial_num_bikes_available_types_mechanical smallint,
    initial_num_bikes_available_types_ebike smallint,
    initial_num_docks_available smallint,
    final_num_bikes_available smallint,
    final_num_bikes_available_types_mechanical smallint,
    final_num_bikes_available_types_ebike smallint,
    final_num_docks_available smallint,
    input_num_bikes_available smallint,
    input_num_bikes_available_types_mechanical smallint,
    input_num_bikes_available_types_ebike smallint,
    input_num_docks_available smallint,
    output_num_bikes_available smallint,
    output_num_bikes_available_types_mechanical smallint,
    output_num_bikes_available_types_ebike smallint,
    output_num_docks_available smallint
)
DELETE FROM stations_timestamps

INSERT INTO stations_timestamps (
	station_status_id,
	station_id,
	last_reported,
    initial_num_bikes_available,
    initial_num_bikes_available_types_mechanical,
    initial_num_bikes_available_types_ebike,
    initial_num_docks_available,
    final_num_bikes_available,
    final_num_bikes_available_types_mechanical,
    final_num_bikes_available_types_ebike,
    final_num_docks_available
) 
SELECT	
	act.id,
	act.station_id,
	act.last_reported,
	ant.num_bikes_available,
	ant.num_bikes_available_types_mechanical,
	ant.num_bikes_available_types_ebike,
	ant.num_docks_available,
	act.num_bikes_available,
	act.num_bikes_available_types_mechanical,
	act.num_bikes_available_types_ebike,
	act.num_docks_available
FROM stations_status_t1_1to100 act -- registro actual
-- tabla de cruce
INNER JOIN stations_status_previous prev on act.id=prev.bicing_station_status_id
-- registro anterior
INNER JOIN stations_status_t1_1to100 ant on prev.previous_bicing_station_status_id=ant.id

INSERT INTO stations_timestamps (
	station_status_id,
	station_id,
	last_reported,
    initial_num_bikes_available,
    initial_num_bikes_available_types_mechanical,
    initial_num_bikes_available_types_ebike,
    initial_num_docks_available,
    final_num_bikes_available,
    final_num_bikes_available_types_mechanical,
    final_num_bikes_available_types_ebike,
    final_num_docks_available
) 
SELECT
	act.id,
	act.station_id,
	act.last_reported,
	ant.num_bikes_available,
	ant.num_bikes_available_types_mechanical,
	ant.num_bikes_available_types_ebike,
	ant.num_docks_available,
	act.num_bikes_available,
	act.num_bikes_available_types_mechanical,
	act.num_bikes_available_types_ebike,
	act.num_docks_available
FROM stations_status_t1_101to200 act -- registro actual
-- tabla de cruce
INNER JOIN stations_status_previous prev on act.id=prev.bicing_station_status_id
-- registro anterior
INNER JOIN stations_status_t1_101to200 ant on prev.previous_bicing_station_status_id=ant.id

INSERT INTO stations_timestamps (
	station_status_id,
	station_id,
	last_reported,
    initial_num_bikes_available,
    initial_num_bikes_available_types_mechanical,
    initial_num_bikes_available_types_ebike,
    initial_num_docks_available,
    final_num_bikes_available,
    final_num_bikes_available_types_mechanical,
    final_num_bikes_available_types_ebike,
    final_num_docks_available
) 
SELECT	
	act.id,
	act.station_id,
	act.last_reported,
	ant.num_bikes_available,
	ant.num_bikes_available_types_mechanical,
	ant.num_bikes_available_types_ebike,
	ant.num_docks_available,
	act.num_bikes_available,
	act.num_bikes_available_types_mechanical,
	act.num_bikes_available_types_ebike,
	act.num_docks_available
FROM stations_status_t1_201to300 act -- registro actual
-- tabla de cruce
INNER JOIN stations_status_previous prev on act.id=prev.bicing_station_status_id
-- registro anterior
INNER JOIN stations_status_t1_201to300 ant on prev.previous_bicing_station_status_id=ant.id

INSERT INTO stations_timestamps (
	station_status_id,
	station_id,
	last_reported,
    initial_num_bikes_available,
    initial_num_bikes_available_types_mechanical,
    initial_num_bikes_available_types_ebike,
    initial_num_docks_available,
    final_num_bikes_available,
    final_num_bikes_available_types_mechanical,
    final_num_bikes_available_types_ebike,
    final_num_docks_available
) 
SELECT
	act.id,
	act.station_id,
	act.last_reported,
	ant.num_bikes_available,
	ant.num_bikes_available_types_mechanical,
	ant.num_bikes_available_types_ebike,
	ant.num_docks_available,
	act.num_bikes_available,
	act.num_bikes_available_types_mechanical,
	act.num_bikes_available_types_ebike,
	act.num_docks_available
FROM stations_status_t1_301to400 act -- registro actual
-- tabla de cruce
INNER JOIN stations_status_previous_part prev on act.id=prev.bicing_station_status_id
-- registro anterior
INNER JOIN stations_status_t1_301to400 ant on prev.previous_bicing_station_status_id=ant.id

INSERT INTO stations_timestamps (
	station_status_id,
	station_id,
	last_reported,
    initial_num_bikes_available,
    initial_num_bikes_available_types_mechanical,
    initial_num_bikes_available_types_ebike,
    initial_num_docks_available,
    final_num_bikes_available,
    final_num_bikes_available_types_mechanical,
    final_num_bikes_available_types_ebike,
    final_num_docks_available
) 
SELECT	
	act.id,
	act.station_id,
	act.last_reported,
	ant.num_bikes_available,
	ant.num_bikes_available_types_mechanical,
	ant.num_bikes_available_types_ebike,
	ant.num_docks_available,
	act.num_bikes_available,
	act.num_bikes_available_types_mechanical,
	act.num_bikes_available_types_ebike,
	act.num_docks_available
FROM stations_status_t1_401to500 act -- registro actual
-- tabla de cruce
INNER JOIN stations_status_previous_part prev on act.id=prev.bicing_station_status_id
-- registro anterior
INNER JOIN stations_status_t1_401to500 ant on prev.previous_bicing_station_status_id=ant.id

INSERT INTO stations_timestamps (
	station_status_id,
	station_id,
	last_reported,
    initial_num_bikes_available,
    initial_num_bikes_available_types_mechanical,
    initial_num_bikes_available_types_ebike,
    initial_num_docks_available,
    final_num_bikes_available,
    final_num_bikes_available_types_mechanical,
    final_num_bikes_available_types_ebike,
    final_num_docks_available
) 
SELECT	
	act.id,
	act.station_id,
	act.last_reported,
	ant.num_bikes_available,
	ant.num_bikes_available_types_mechanical,
	ant.num_bikes_available_types_ebike,
	ant.num_docks_available,
	act.num_bikes_available,
	act.num_bikes_available_types_mechanical,
	act.num_bikes_available_types_ebike,
	act.num_docks_available
FROM stations_status_t1_501to600 act -- registro actual
-- tabla de cruce
INNER JOIN stations_status_previous_part prev on act.id=prev.bicing_station_status_id
-- registro anterior
INNER JOIN stations_status_t1_501to600 ant on prev.previous_bicing_station_status_id=ant.id

-- primero ejecutaremos restas. Luego, lo que quede negativo lo dejaremos a cero. Inicio: 11:05
UPDATE stations_timestamps SET
	input_num_bikes_available=final_num_bikes_available-initial_num_bikes_available,
	input_num_bikes_available_types_mechanical=final_num_bikes_available_types_mechanical-initial_num_bikes_available_types_mechanical,
	input_num_bikes_available_types_ebike=final_num_bikes_available_types_ebike-initial_num_bikes_available_types_ebike,
	input_num_docks_available=final_num_docks_available-initial_num_docks_available,
	output_num_bikes_available=initial_num_bikes_available-final_num_bikes_available,
	output_num_bikes_available_types_mechanical=initial_num_bikes_available_types_mechanical-final_num_bikes_available_types_mechanical,
	output_num_bikes_available_types_ebike=initial_num_bikes_available_types_ebike-final_num_bikes_available_types_ebike,
	output_num_docks_available=initial_num_docks_available-final_num_docks_available
	
UPDATE stations_timestamps SET
	input_num_bikes_available=0
WHERE input_num_bikes_available<0;

UPDATE stations_timestamps SET
	input_num_bikes_available_types_mechanical=0
WHERE input_num_bikes_available_types_mechanical<0;

UPDATE stations_timestamps SET 
	input_num_bikes_available_types_ebike=0
WHERE input_num_bikes_available_types_ebike<0;

UPDATE stations_timestamps SET 
	input_num_docks_available=0
WHERE input_num_docks_available<0;

UPDATE stations_timestamps SET 
	output_num_bikes_available=0
WHERE output_num_bikes_available<0;

UPDATE stations_timestamps SET 
	output_num_bikes_available_types_mechanical=0
WHERE output_num_bikes_available_types_mechanical<0;

UPDATE stations_timestamps SET 
	output_num_bikes_available_types_ebike=0
WHERE output_num_bikes_available_types_ebike<0;

UPDATE stations_timestamps SET 
	output_num_docks_available=0
WHERE output_num_docks_available<0;

UPDATE timestamps_intervals SET
	year=EXTRACT(YEAR FROM interval_to),
	month=EXTRACT(MONTH FROM interval_to)

-- creamos índices para poder agilizar consultas
CREATE INDEX idx_intervals_from_to ON timestamps_intervals (interval_from, interval_to);

--------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.stations_intervals
(
	station_id smallint not null,
	interval_id integer not null,
	min_station_status_id integer not null,
	max_station_status_id integer not null,
    input_num_bikes_available int,
    input_num_bikes_available_types_mechanical int,
    input_num_bikes_available_types_ebike int,
    input_num_docks_available int,
    output_num_bikes_available int,
    output_num_bikes_available_types_mechanical int,
    output_num_bikes_available_types_ebike int,
    output_num_docks_available int
)

--Hacemos particiones de la tabla stations_timestamps, porque se ha intentado ejecutar siguientes pasos con tabla entera, pero los tiempos de ejecución son inmanejables.
SELECT * 
INTO station_timestamps_1to100 
FROM stations_timestamps
WHERE station_id BETWEEN 1 AND 100

CREATE INDEX idx_lastreported1to100 ON station_timestamps_1to100 (last_reported);	

-- 4'33"
INSERT INTO stations_intervals
SELECT
	stat.station_id,
	tsi.id,
	MIN(stat.station_status_id),
	MAX(stat.station_status_id),
	SUM(input_num_bikes_available),
	SUM(input_num_bikes_available_types_mechanical),
	SUM(input_num_bikes_available_types_ebike),
	SUM(input_num_docks_available),
	SUM(output_num_bikes_available),
	SUM(output_num_bikes_available_types_mechanical),
	SUM(output_num_bikes_available_types_ebike),
	SUM(output_num_docks_available)
FROM station_timestamps_1to100 stat
INNER JOIN timestamps_intervals_hours tsi ON stat.last_reported between tsi.interval_from AND tsi.interval_to
GROUP BY
	stat.station_id,
	tsi.id
	
SELECT * 
INTO station_timestamps_101to200 
FROM stations_timestamps
WHERE station_id between 101 and 200	

CREATE INDEX idx_lastreported101to200 ON station_timestamps_101to200 (last_reported);

INSERT INTO stations_intervals
SELECT
	stat.station_id,
	tsi.id,
	MIN(stat.station_status_id),
	MAX(stat.station_status_id),
	SUM(input_num_bikes_available),
	SUM(input_num_bikes_available_types_mechanical),
	SUM(input_num_bikes_available_types_ebike),
	SUM(input_num_docks_available),
	SUM(output_num_bikes_available),
	SUM(output_num_bikes_available_types_mechanical),
	SUM(output_num_bikes_available_types_ebike),
	SUM(output_num_docks_available)
FROM station_timestamps_101to200 stat
INNER JOIN timestamps_intervals_hours tsi ON stat.last_reported between tsi.interval_from AND tsi.interval_to
GROUP BY
	stat.station_id,
	tsi.id
	
CREATE INDEX idx_lastreported201to300 ON station_timestamps_201to300 (last_reported);	

INSERT INTO stations_intervals
SELECT
	stat.station_id,
	tsi.id,
	MIN(stat.station_status_id),
	MAX(stat.station_status_id),
	SUM(input_num_bikes_available),
	SUM(input_num_bikes_available_types_mechanical),
	SUM(input_num_bikes_available_types_ebike),
	SUM(input_num_docks_available),
	SUM(output_num_bikes_available),
	SUM(output_num_bikes_available_types_mechanical),
	SUM(output_num_bikes_available_types_ebike),
	SUM(output_num_docks_available)
FROM station_timestamps_201to300 stat
INNER JOIN timestamps_intervals_hours tsi ON stat.last_reported between tsi.interval_from AND tsi.interval_to
GROUP BY
	stat.station_id,
	tsi.id
	
SELECT * 
INTO station_timestamps_301to400 
FROM stations_timestamps
WHERE station_id between 301 and 400
	
CREATE INDEX idx_lastreported301to400 ON station_timestamps_301to400 (last_reported);	
	
INSERT INTO stations_intervals
SELECT
	stat.station_id,
	tsi.id,
	MIN(stat.station_status_id),
	MAX(stat.station_status_id),
	SUM(input_num_bikes_available),
	SUM(input_num_bikes_available_types_mechanical),
	SUM(input_num_bikes_available_types_ebike),
	SUM(input_num_docks_available),
	SUM(output_num_bikes_available),
	SUM(output_num_bikes_available_types_mechanical),
	SUM(output_num_bikes_available_types_ebike),
	SUM(output_num_docks_available)
FROM station_timestamps_301to400 stat
INNER JOIN timestamps_intervals_hours tsi ON stat.last_reported between tsi.interval_from AND tsi.interval_to
GROUP BY
	stat.station_id,
	tsi.id

SELECT * 
INTO station_timestamps_401to500 
FROM stations_timestamps
WHERE station_id BETWEEN 401 AND 500
	
CREATE INDEX idx_lastreported401to500 ON station_timestamps_401to500 (last_reported);		

INSERT INTO stations_intervals
SELECT
	stat.station_id,
	tsi.id,
	MIN(stat.station_status_id),
	MAX(stat.station_status_id),
	SUM(input_num_bikes_available),
	SUM(input_num_bikes_available_types_mechanical),
	SUM(input_num_bikes_available_types_ebike),
	SUM(input_num_docks_available),
	SUM(output_num_bikes_available),
	SUM(output_num_bikes_available_types_mechanical),
	SUM(output_num_bikes_available_types_ebike),
	SUM(output_num_docks_available)
FROM station_timestamps_401to500 stat
INNER JOIN timestamps_intervals_hours tsi ON stat.last_reported BETWEEN tsi.interval_from AND tsi.interval_to
GROUP BY
	stat.station_id,
	tsi.id
	
SELECT *
INTO station_timestamps_501to600 
FROM stations_timestamps
WHERE station_id BETWEEN 501 AND 600
	
CREATE INDEX idx_lastreported501to600 ON station_timestamps_501to600 (last_reported);		
	
INSERT INTO stations_intervals
SELECT
	stat.station_id,
	tsi.id,
	min(stat.station_status_id),
	max(stat.station_status_id),
	sum(input_num_bikes_available),
	sum(input_num_bikes_available_types_mechanical),
	sum(input_num_bikes_available_types_ebike),
	sum(input_num_docks_available),
	sum(output_num_bikes_available),
	sum(output_num_bikes_available_types_mechanical),
	sum(output_num_bikes_available_types_ebike),
	sum(output_num_docks_available)
FROM station_timestamps_501to600 stat
INNER JOIN timestamps_intervals_hours tsi ON stat.last_reported between tsi.interval_from AND tsi.interval_to
GROUP BY
	stat.station_id,
	tsi.id
	
-- ahora por 30'
-- También hacemos particiones de la tabla de intervalos, para recortar tiempos de ejecución
SELECT * INTO timestamps_intervals_hours
FROM timestamps_intervals
WHERE interval_type='hours'
CREATE INDEX idx_timestamps_intervals_hours_from_to ON timestamps_intervals_hours (interval_from, interval_to);

SELECT * 
INTO timestamps_intervals_30min
FROM timestamps_intervals
WHERE interval_type='minutes' AND interval_value=30

CREATE INDEX idx_timestamps_intervals_30min_from_to ON timestamps_intervals_30min (interval_from, interval_to);

-- separamos los registros de stations_intervals correspondientes a la partición de intervalos de 30 minutos.
-- Esto nos servirá para traspasar a cloud y desde allí anexar la información de stations_intervals_30min a la tabla stations_intervals
CREATE TABLE public.stations_intervals_30min (
	station_id int2 NOT NULL,
	interval_id int4 NOT NULL,
	min_station_status_id int4 NOT NULL,
	max_station_status_id int4 NOT NULL,
	input_num_bikes_available int4 NULL,
	input_num_bikes_available_types_mechanical int4 NULL,
	input_num_bikes_available_types_ebike int4 NULL,
	input_num_docks_available int4 NULL,
	output_num_bikes_available int4 NULL,
	output_num_bikes_available_types_mechanical int4 NULL,
	output_num_bikes_available_types_ebike int4 NULL,
	output_num_docks_available int4 NULL
);

INSERT INTO stations_intervals_30min
SELECT
	stat.station_id,
	tsi.id,
	MIN(stat.station_status_id),
	MAX(stat.station_status_id),
	SUM(input_num_bikes_available),
	SUM(input_num_bikes_available_types_mechanical),
	SUM(input_num_bikes_available_types_ebike),
	SUM(input_num_docks_available),
	SUM(output_num_bikes_available),
	SUM(output_num_bikes_available_types_mechanical),
	SUM(output_num_bikes_available_types_ebike),
	SUM(output_num_docks_available)
FROM station_timestamps_1to100 stat
INNER JOIN timestamps_intervals_30min tsi ON stat.last_reported between tsi.interval_from AND tsi.interval_to
GROUP BY
	stat.station_id,
	tsi.id;

INSERT INTO stations_intervals_30min
SELECT
	stat.station_id,
	tsi.id,
	MIN(stat.station_status_id),
	MAX(stat.station_status_id),
	SUM(input_num_bikes_available),
	SUM(input_num_bikes_available_types_mechanical),
	SUM(input_num_bikes_available_types_ebike),
	SUM(input_num_docks_available),
	SUM(output_num_bikes_available),
	SUM(output_num_bikes_available_types_mechanical),
	SUM(output_num_bikes_available_types_ebike),
	SUM(output_num_docks_available)
FROM station_timestamps_101to200 stat
INNER JOIN timestamps_intervals_30min tsi ON stat.last_reported between tsi.interval_from AND tsi.interval_to
GROUP BY
	stat.station_id,
	tsi.id;

INSERT INTO stations_intervals_30min
SELECT
	stat.station_id,
	tsi.id,
	MIN(stat.station_status_id),
	MAX(stat.station_status_id),
	SUM(input_num_bikes_available),
	SUM(input_num_bikes_available_types_mechanical),
	SUM(input_num_bikes_available_types_ebike),
	SUM(input_num_docks_available),
	SUM(output_num_bikes_available),
	SUM(output_num_bikes_available_types_mechanical),
	SUM(output_num_bikes_available_types_ebike),
	SUM(output_num_docks_available)
FROM station_timestamps_201to300 stat
INNER JOIN timestamps_intervals_30min tsi ON stat.last_reported between tsi.interval_from AND tsi.interval_to
GROUP BY
	stat.station_id,
	tsi.id;

INSERT INTO stations_intervals_30min
SELECT
	stat.station_id,
	tsi.id,
	MIN(stat.station_status_id),
	MAX(stat.station_status_id),
	SUM(input_num_bikes_available),
	SUM(input_num_bikes_available_types_mechanical),
	SUM(input_num_bikes_available_types_ebike),
	SUM(input_num_docks_available),
	SUM(output_num_bikes_available),
	SUM(output_num_bikes_available_types_mechanical),
	SUM(output_num_bikes_available_types_ebike),
	SUM(output_num_docks_available)
FROM station_timestamps_301to400 stat
INNER JOIN timestamps_intervals_30min tsi ON stat.last_reported between tsi.interval_from AND tsi.interval_to
GROUP BY
	stat.station_id,
	tsi.id;

INSERT INTO stations_intervals_30min
SELECT
	stat.station_id,
	tsi.id,
	MIN(stat.station_status_id),
	MAX(stat.station_status_id),
	SUM(input_num_bikes_available),
	SUM(input_num_bikes_available_types_mechanical),
	SUM(input_num_bikes_available_types_ebike),
	SUM(input_num_docks_available),
	SUM(output_num_bikes_available),
	SUM(output_num_bikes_available_types_mechanical),
	SUM(output_num_bikes_available_types_ebike),
	SUM(output_num_docks_available)
FROM station_timestamps_401to500 stat
INNER JOIN timestamps_intervals_30min tsi ON stat.last_reported between tsi.interval_from AND tsi.interval_to
GROUP BY
	stat.station_id,
	tsi.id;

INSERT INTO stations_intervals_30min
SELECT
	stat.station_id,
	tsi.id,
	MIN(stat.station_status_id),
	MAX(stat.station_status_id),
	SUM(input_num_bikes_available),
	SUM(input_num_bikes_available_types_mechanical),
	SUM(input_num_bikes_available_types_ebike),
	SUM(input_num_docks_available),
	SUM(output_num_bikes_available),
	SUM(output_num_bikes_available_types_mechanical),
	SUM(output_num_bikes_available_types_ebike),
	SUM(output_num_docks_available)
FROM station_timestamps_501to600 stat
INNER JOIN timestamps_intervals_30min tsi ON stat.last_reported between tsi.interval_from AND tsi.interval_to
GROUP BY
	stat.station_id,
	tsi.id;
