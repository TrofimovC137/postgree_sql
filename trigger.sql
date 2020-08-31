--DROP TRIGGER IF EXISTS recept_triger ON recgoods;

CREATE OR REPLACE FUNCTION recept_triger_f() RETURNS TRIGGER AS $$
	DECLARE _row record;
	DECLARE recept_value int;
	DECLARE remainds_recept_value int;
	BEGIN
	IF (NEW.id IS NULL) OR
		(NEW.subid IS NULL) OR
		(NEW.goods IS NULL) OR
		(NEW.volume IS NULL) OR
		(NEW.price IS NULL)
		THEN RAISE EXCEPTION 'invalid value';
	END IF;
	--Проверка на то, что Insert не нарушает логики и не образуется отрицательных остатков
	--в последующих записях (если такие существуют)
	IF
		(SELECT COUNT(*) 
		FROM (
			SELECT (remaind-NEW.volume) < 0 as flag_
			FROM remainds
			WHERE remainds.storage = NEW.storage AND
				remainds.goods = NEW.goods AND
				remainds.ddate >= NEW.ddate) t
		WHERE t.flag_ = 'true'::boolean)
	THEN RAISE EXCEPTION 'REMAINS < 0';
	END IF;
	--Для заполнения irlink по lifo создадим таблицу приходов до даты recept-а
	CREATE TEMP TABLE all_inc(id integer,
							   subid integer,
							   goods integer,
							   volume integer,
							   ddate date,
							   storage integer);
	INSERT INTO all_inc(id, subid, goods, volume, ddate, storage)
		SELECT
  			incgoods.id,
  			incgoods.subid,
  			incgoods.goods,
  			incgoods.volume,
  			income.ddate,
  			income.storage
		FROM
  			incgoods
  			JOIN income ON income.id = incgoods.id
  			JOIN recept ON recept.id = NEW.id
		WHERE
  			income.ddate < recept.ddate
  			AND goods = NEW.goods
  			AND income.storage = recept.storage
		ORDER BY ddate DESC;
	--по данной таблице можно заполнить irlink
	recept_value = NEW.volume;
	FOR _row IN SELECT * FROM all_inc LOOP remainds_recept_value = _row.volume - recept_value;
	IF remainds_recept_value < 0 THEN remainds_recept_value = 0; END IF;
	remainds_recept_value = remainds_recept_value - _row.volume;
	--из записи прихода взят уход recept-a
	INSERT INTO irlink(i_id, i_subid, r_id, r_subid, goods, volume) VALUES
	(_row.id, _row.subid, NEW.id, NEW.subid, NEW.goods, (_row.vlolume - remainds_recept_value));
	END LOOP;
	--обновление остатков
	--т.к. до этого была проверка, insert не должен вызвать конфликтов
	UPDATE remainds
	SET remaind = remaind - NEW.volume
		WHERE remainds.storage = NEW.storage AND
		remainds.goods = NEW.goods AND
		remainds.ddate >= NEW.ddate;
	DROP TABLE all_inc;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER recept_triger BEFORE INSERT ON recgoods
FOR EACH ROW EXECUTE PROCEDURE recept_triger_f();