CREATE OR REPLACE FUNCTION fnc_epoch_inicio_mes(
    year_in INT,
    month_in INT
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    ts TIMESTAMP;
    epoch_result BIGINT;
BEGIN
    -- Crear un timestamp para el primer día del mes a las 00:00:00
    ts := make_timestamp(year_in, month_in, 1, 0, 0, 0);

    -- Convertir el timestamp a epoch
    epoch_result := EXTRACT(EPOCH FROM ts)::bigint;

    RETURN epoch_result;
END;
$$;
