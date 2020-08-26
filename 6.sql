--1) Давайте создадим и заполним таблицу по поставкам в разрезе дней и складов: 
--2) Дата, Склад, Сумма руб., Объем м3, Число разных товаров
CREATE TABLE delivery (ddate date, storage text, summ numeric, volume numeric, goods_unic_count bigint);
INSERT INTO delivery(ddate, storage, summ, volume, goods_unic_count)
SELECT
	income.ddate,
	storage.name,
	SUM(incgoods.volume * incgoods.price) AS Summ,
	SUM(goods.height * goods.length * incgoods.volume) AS Volume,
	COUNT(DISTINCT incgoods.goods)
FROM income
JOIN storage ON income.storage = storage.id
JOIN incgoods ON income.id = incgoods.id
JOIN goods ON goods.id = incgoods.goods
GROUP BY income.ddate, storage.name;

--Давайте заведем у Склада поле Признак активности.
--Написать запрос, который установит Признак = 1, если со склада были продажи
--более чем на 10000 руб. за  месяц.

--ALTER TABLE storage ADD COLUMN flag int;

DO $$
DECLARE 
	month_date date := '01-01-2020';
BEGIN 
	WITH storage_flag_id AS(
		SELECT 
			recept.storage,
			SUM(recgoods.price * recgoods.volume) AS month_rec_summ
		FROM
			recept
			JOIN recgoods ON recept.id = recgoods.id
		WHERE
			recept.ddate >= month_date
		GROUP BY recept.storage
		HAVING SUM(recgoods.price * recgoods.volume) > 10000
	)
	UPDATE storage SET flag = 1
	WHERE id IN (
		SELECT storage from storage_flag_id
	);
END $$;
	
--Удаление из таблицы товаров всех товаров, по которым не было ни продажь ни поставок

DELETE FROM 
	goods
WHERE
	id NOT IN (SELECT goods FROM recgoods UNION SELECT goods FROM incgoods)
	