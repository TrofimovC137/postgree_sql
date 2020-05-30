CREATE TABLE income_date_storage(
	ddate date,
	storage TEXT,
	sum_ DECIMAL(18,4),
	volume int,
	count_uniq_goods int);

INSERT INTO income_date_storage(ddate, storage, sum_, volume, count_uniq_goods)
	SELECT 
		income.ddate,
		storage.name, 
		SUM(incgoods.price * incgoods.volume) AS sum_,
		SUM(goods.height * goods.width * goods.length * incgoods.volume) AS volume, COUNT(DISTINCT incgoods.goods)                 
	FROM 
		income
		JOIN storage ON income.storage = storage.id
		JOIN incgoods ON income.id = incgoods.id
		JOIN goods ON goods.id = incgoods.goods
	GROUP BY income.ddate,storage.name;
	
	
	ALTER TABLE storage ADD COLUMN flag int;
	
WITH rec_ AS (
	SELECT 
		recept.storage,
		SUM(recgoods.volume * recgoods.price) AS sum_ 
	FROM 
		recept
		JOIN recgoods ON recept.id = recgoods.id
	WHERE 
		recept.ddate > date_trunc('month', current_date - interval '1' month)
	GROUP BY 
		recept.storage
	HAVING 
		SUM(recgoods.volume * recgoods.price) > 10000)

UPDATE storage SET flag = 1
WHERE id in (SELECT
			 	storage 
			 FROM  
			 	rec_);