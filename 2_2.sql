--Прайсы партнеров из грппы на конкретную дату
CREATE TABLE price_on_date(name VARCHAR(255), price numeric(18, 4));
DO $$
DECLARE  day_date date = '2020-02-01';
DECLARE partner_id int = 2;
BEGIN
	INSERT INTO price_on_date(name, price)
	WITH good AS (
		SELECT *
		FROM price_list_
			JOIN goods ON goods.id = price_list_.goods_id
			JOIN partners_groups_ ON partners_groups_.partner_group_id = goods.group_id
	)
	SELECT DISTINCT good.name, good.price 
	FROM price_list_
		JOIN good ON good.price_list_id = price_list_.price_list_id
	WHERE
		good.partner_group_id = partner_id AND
		good.ddate = day_date;
END $$;