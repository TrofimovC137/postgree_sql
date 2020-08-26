--Остатки на складах в разрезе: дата-склад-товар-количество
CREATE TABLE remainds(ddate date, storage text, goods int, remaind bigint);
INSERT INTO remainds(ddate, storage, goods, remaind)
WITH date_range  AS(select x+'01-03-2020'::date ddate from generate_series(0, 13) x)
SELECT 
	all_inc.inc_date AS ddate,
	all_inc.inc_storage AS storage, 
	all_inc.inc_goods AS goods,
	CASE
		WHEN all_inc.inc_sum IS null THEN -all_rec.rec_sum
		WHEN all_rec.rec_sum IS null THEN all_inc.inc_sum
		ELSE all_inc.inc_sum - all_rec.rec_sum 
	END AS remaind
FROM
(select 
	date_range.ddate as inc_date, 
	income.storage as inc_storage, 
	incgoods.goods as inc_goods, 
	sum(incgoods.volume) as inc_sum
from income
	JOIN incgoods ON incgoods.id=income.id
	JOIN date_range ON income.ddate <= date_range.ddate
GROUP BY
	date_range.ddate, inc_storage, inc_goods) as all_inc
FULL JOIN
(select 
	date_range.ddate as rec_date, 
	recept.storage as rec_storage, 
	recgoods.goods as rec_goods, 
	sum(recgoods.volume) as rec_sum
from recept
	JOIN recgoods ON recgoods.id=recept.id
	JOIN date_range ON recept.ddate <= date_range.ddate
GROUP BY
	date_range.ddate, rec_storage, rec_goods) as all_rec
ON inc_date = rec_date and inc_storage = rec_storage and inc_goods = rec_goods
ORDER BY ddate