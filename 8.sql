-- скользящее среднее по складу-товару
CREATE OR REPLACE FUNCTION my_qvg_predict(k decimal(18, 4), start_date date, end_date date)
RETURNS table(ddate date, storage int, goods int, summ numeric, errors numeric) AS $$
DECLARE
storage_ integer;
goods_ integer;
sum_ numeric;
sum_predict numeric;
sum_predict_ numeric;
ddate_ date;

curs CURSOR FOR SELECT recept.storage, recgoods.goods, SUM(recgoods.price) sum_, recept.ddate
	FROM recept
		JOIN recgoods ON recgoods.id = recept.id
		JOIN goods on recgoods.goods = goods.id
	WHERE
		recept.ddate BETWEEN start_date AND end_date
	GROUP BY
		recept.ddate, recept.storage, recgoods.goods;
BEGIN
	OPEN curs;
	CREATE TEMP TABLE tmp(ddate date, storage int, goods int, summ numeric, errors numeric);
	goods_ = null;
	storage_ = null;
	sum_predict_ = 0;
	LOOP
	FETCH curs INTO storage, goods, sum_, ddate_;
	EXIT WHEN NOT FOUND;
	IF storage_ != storage and goods_ != goods 
		THEN sum_predict = sum/k;
	ELSE sum_predict = (SELECT avg(price) FROM(
							SELECT recept.ddate, price
							FROM recept JOIN recgoods ON recept.id = recgoods.id
							WHERE recept.ddate <= ddate_ AND recept.storage = storage_ AND recgoods.goods = goods_
							ORDER BY ddate LIMIT 10)last_k); END IF;
	goods_ = goods;
	sum_predict_ = sum_predict;
	
	INSERT INTO tmp(ddate, storage, goods, summ, errors) VALUES
	(ddate, storage, goods, sum_predict, ABS(sum_predict-sum_));
	END LOOP;
	CLOSE curs;
	RETURN QUERY SELECT * FROM tmp;
	DROP TABLE tmp;
END;
$$
LANGUAGE plpgsql;
