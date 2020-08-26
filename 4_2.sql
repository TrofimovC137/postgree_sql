SELECT DISTINCT
	t.key_1,
	t.key_2,
	sum(t.data1) over ( partition by t.key_1, t.key_2 ) as SUM,
	min(t.data2) over ( partition by t.key_1, t.key_2 ) as MIN
FROM
	t