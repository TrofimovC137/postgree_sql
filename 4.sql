CREATE TABLE t(
	key_1 int,
	key_2 int,
	data1 int,
	data2 int
);
INSERT INTO t(key_1, key_2, data1, data2)VALUES
(1, 1, 10, 46),
(1, 1, 10, 22),
(1, 2, 12, 58),
(2, 1, 5, 42),
(2, 1, 5, 55),
(2, 2, 8, 99);

SELECT 
	key_1,
	key_2,
	SUM(data1),
	MIN(data2)
FROM
	t
GROUP BY
	key_1,
	key_2;
	
SELECT DISTINCT
	t.key_1,
	t.key_2,
	sum(t.data1) over ( partition by t.key_1, t.key_2 ) as SUM,
	min(t.data2) over ( partition by t.key_1, t.key_2 ) as MIN
FROM
	t