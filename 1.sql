CREATE TABLE prices(
	ddate date,
	price decimal(18,4),
	goods_id int
);
INSERT INTO prices(ddate, price,goods_id)VALUES
	('01-05-2020', 100, 1),
	('02-05-2020', 120, 1),
	('06-05-2020', 3000, 2),
	('09-05-2020', 115, 1),
	('10-05-2020', 3050, 2);

SELECT 
	price
FROM
	prices
WHERE 
	goods_id = 1 AND
	ddate = (SELECT  MAX(prices_.ddate) 
			 FROM prices prices_
			 WHERE prices.goods_id = prices_.goods_id  AND prices_.ddate < '10-05-2020')