-- Контрольная на создание последовательности

CREATE OR REPLACE FUNCTION ARANGE(shape0 int, shape1 int)
RETURNS TABLE (value integer) AS $$
BEGIN
	RETURN QUERY SELECT *
		FROM generate_series(shape0, shape1);
END;
$$
LANGUAGE plpgsql;

SELECT *
FROM ARANGE(1, 10);