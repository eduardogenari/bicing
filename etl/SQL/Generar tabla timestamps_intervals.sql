--delete from timestamps_intervals
DO $$
DECLARE
    start_time TIMESTAMP := '2021-01-01 00:00:00'; -- Cambia esta fecha y hora
    end_time TIMESTAMP := '2025-12-31 23:59:59';   -- Cambia esta fecha y hora
    interval_type TEXT := 'minutes';              -- Cambia a 'hours', 'days', etc.
    interval_value INTEGER := 30;                  -- Valor del intervalo (e.g., 5 minutos, 2 horas)
    cur_time TIMESTAMP := start_time;             -- Variable para el bucle
    prev_time TIMESTAMP;                          -- Para poder guardar "desde"
    interval_duration INTERVAL;                  -- Variable para calcular el intervalo real
BEGIN
    -- Calcula el intervalo real basado en el tipo y valor
    IF interval_type = 'minutes' THEN
        interval_duration := INTERVAL '1 minute' * interval_value;
    ELSIF interval_type = 'hours' THEN
        interval_duration := INTERVAL '1 hour' * interval_value;
    ELSIF interval_type = 'days' THEN
        interval_duration := INTERVAL '1 day' * interval_value;
    ELSE
        RAISE EXCEPTION 'Tipo de intervalo no soportado: %', interval_type;
    END IF;
    
    -- Inicializamos prev_time para la primera vez 
    prev_time := start_time - interval_duration;

    -- Inserta los datos en la tabla
    WHILE cur_time <= end_time LOOP
        INSERT INTO timestamps_intervals (timestamp, interval_type, interval_value, interval_from, interval_to)
        VALUES (cur_time, interval_type, interval_value, prev_time + INTERVAL '1 millisecond', cur_time);
        prev_time := cur_time;
        cur_time := cur_time + interval_duration;
    END LOOP;
END $$;
